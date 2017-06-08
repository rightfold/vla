module Main.Server
  ( main
  ) where

import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Hyper.Drive (Request, Response, hyperdrive, response, status)
import Hyper.Node.Server (defaultOptionsWithLogging, runServer)
import Hyper.Status (statusBadRequest, statusNotFound)
import Stuff hiding (all)
import VLA.CRM.Account.Web (fetchAccount, updateAccount)

main :: IOSync Unit
main = liftEff $ runServer defaultOptionsWithLogging {} (hyperdrive all)

all :: ∀ f r. Applicative f => Request String r -> f (Response String)
all req = case (unwrap req).url of
  "/CRM/Account/fetchAccount" -> overJSON fetchAccount req
  "/CRM/Account/updateAccount" -> overJSON updateAccount req
  _ -> response "null" # status statusNotFound # pure

overJSON
  :: ∀ f r i o
   . Applicative f
  => DecodeJson i
  => EncodeJson o
  => (Request i r -> f (Response o))
  -> (Request String r -> f (Response String))
overJSON app req =
  either onBadRequest (map mapResponse \ onRequest) $
    decodeJson =<< jsonParser (unwrap req).body
  where
  onBadRequest = response >>> status statusBadRequest >>> pure
  onRequest = app \ (lmap <@> req) \ const
  mapResponse = map (stringify \ encodeJson)
