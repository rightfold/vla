module VLA.CRM.Account
  ( AccountID(..)
  , Account(..)
  , accountEnabled
  , accountName
  ) where

import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.String.NonEmpty (NonEmptyString)
import Data.UUID (UUID)
import Stuff

newtype AccountID = AccountID UUID

data Account = Account Boolean NonEmptyString

accountEnabled :: Account -> Boolean
accountEnabled (Account enabled _) = enabled

accountName :: Account -> NonEmptyString
accountName (Account _ name) = name

derive newtype instance i3 :: EncodeJson AccountID
derive newtype instance i4 :: DecodeJson AccountID

instance i1 :: EncodeJson Account where
  encodeJson (Account enabled name) = encodeJson (enabled /\ name)

instance i2 :: DecodeJson Account where
  decodeJson = decodeJson >=> \(enabled /\ name) ->
    Account
    <$> decodeJson enabled
    <*> decodeJson name
