module Main.Server
  ( main
  ) where

import Control.Monad.Eff.Exception as Error
import Control.Monad.Free (foldFree)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.HTTP.Method (Method(..))
import Hyper.Drive (Request, Response, header, hyperdrive, response, status)
import Hyper.Node.Server (defaultOptionsWithLogging, runServer)
import Hyper.Status (statusBadRequest, statusMethodNotAllowed, statusNotFound)
import Stuff hiding (all)
import VLA.CRM.Account.Algebra (Accounts, createAccount, fetchAccount, updateAccount)
import VLA.CRM.Account.Dummy as Account.Dummy
import VLA.CRM.Account.Log as Account.Log

--------------------------------------------------------------------------------

main :: IOSync Unit
main = liftEff \ runServer defaultOptionsWithLogging {} $
  hyperdrive (runIO' \ all)

all :: ∀ f r. MonadIOSync f => MonadRec f => Request String r -> f (Response String)
all = withCORS $ withMethodCheck $ \req -> case (unwrap req).url of
  "/CRM/Account/fetchAccount" -> handle (foldFree runAccounts) fetchAccount req
  "/CRM/Account/createAccount" -> handle (foldFree runAccounts) (uncurry createAccount) req
  "/CRM/Account/updateAccount" -> handle (foldFree runAccounts) (uncurry updateAccount) req
  _ -> response "null" # status statusNotFound # pure

--------------------------------------------------------------------------------

runAccounts :: ∀ m a. MonadIOSync m => Accounts a -> m a
runAccounts = (*>) <$> Account.Log.runAccounts <*> Account.Dummy.runAccounts

--------------------------------------------------------------------------------

withCORS
  :: ∀ f i o r
   . Functor f
  => (Request i r -> f (Response o))
  -> Request i r
  -> f (Response o)
withCORS go req =
  header ("Access-Control-Allow-Headers" /\ "Content-Type") <$>
  header ("Access-Control-Allow-Methods" /\ "POST, OPTIONS") <$>
  header ("Access-Control-Allow-Origin" /\ "*") <$>
  go req

withMethodCheck
  :: ∀ f i r
   . Applicative f
  => (Request i r -> f (Response String))
  -> Request i r
  -> f (Response String)
withMethodCheck go req =
  case (unwrap req).method of
    Left POST -> go req
    Left OPTIONS -> response "null" # pure
    _ -> response "null" # status statusMethodNotAllowed # pure

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
