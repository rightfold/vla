module Main.Server
  ( main
  ) where

import Control.Monad.Eff.Exception as Error
import Control.Monad.Free (foldFree)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Hyper.Drive (Request, Response, hyperdrive, response, status)
import Hyper.Node.Server (defaultOptionsWithLogging, runServer)
import Hyper.Status (statusBadRequest, statusNotFound)
import Stuff hiding (all)
import VLA.CRM.Account.Algebra (Accounts, fetchAccount, updateAccount)
import VLA.CRM.Account.Dummy as Account.Dummy
import VLA.CRM.Account.Log as Account.Log

--------------------------------------------------------------------------------

main :: IOSync Unit
main = liftEff \ runServer defaultOptionsWithLogging {} $
  hyperdrive (runIO' \ all)

all :: ∀ f r. MonadIOSync f => MonadRec f => Request String r -> f (Response String)
all req = case (unwrap req).url of
  "/CRM/Account/fetchAccount" -> handle (foldFree runAccounts) fetchAccount req
  "/CRM/Account/updateAccount" -> handle (foldFree runAccounts) (uncurry updateAccount) req
  _ -> response "null" # status statusNotFound # pure

--------------------------------------------------------------------------------

runAccounts :: ∀ m a. MonadIOSync m => Accounts a -> m a
runAccounts = (*>) <$> Account.Log.runAccounts <*> Account.Dummy.runAccounts

--------------------------------------------------------------------------------

handle
  :: ∀ f f' i o r
   . Applicative f'
  => DecodeJson i
  => EncodeJson o
  => (f ~> f')
  -> (i -> f (Either Error o))
  -> Request String r -> f' (Response String)
handle interpret action = overJSON \req ->
  map (response \ lmap Error.message) $
    interpret $ action (unwrap req).body

overJSON
  :: ∀ f r i o
   . Applicative f
  => DecodeJson i
  => EncodeJson o
  => (Request i r -> f (Response o))
  -> Request String r
  -> f (Response String)
overJSON app req =
  either onBadRequest (map mapResponse \ onRequest) $
    decodeJson =<< jsonParser (unwrap req).body
  where
  onBadRequest = response >>> status statusBadRequest >>> pure
  onRequest = app \ (lmap <@> req) \ const
  mapResponse = map (stringify \ encodeJson)
