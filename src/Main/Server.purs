module Main.Server
  ( main
  ) where

import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Hyper.Drive (Application, Request, Response, hyperdrive, response, status)
import Hyper.Node.Server (defaultOptionsWithLogging, runServer)
import Hyper.Status (statusBadRequest)
import Stuff hiding (all)
import VLA.CRM.Account.Web (updateAccount)

main :: IOSync Unit
main = liftEff $ runServer defaultOptionsWithLogging {} (hyperdrive all)

all :: ∀ f r. Applicative f => Application f (Request String r) (Response String)
all = overJSON updateAccount

overJSON
  :: ∀ f r i o
   . Applicative f
  => DecodeJson i
  => EncodeJson o
  => Application f (Request i r) (Response o)
  -> Application f (Request String r) (Response String)
overJSON app req =
  either onBadRequest (map mapResponse \ onRequest) $
    decodeJson =<< jsonParser (unwrap req).body
  where
  onBadRequest = response >>> status statusBadRequest >>> pure
  onRequest = app \ (lmap <@> req) \ const
  mapResponse = map (stringify \ encodeJson)
