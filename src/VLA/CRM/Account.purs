module VLA.CRM.Account
  ( AccountID(..)
  , newAccountID

  , Account(..)
  , accountEnabled
  , accountName
  ) where

import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.String.NonEmpty (NonEmptyString)
import Data.UUID (UUID, newUUID)
import Stuff

--------------------------------------------------------------------------------

newtype AccountID = AccountID UUID

newAccountID :: ∀ m. MonadIOSync m => m AccountID
newAccountID = AccountID <$> newUUID

instance i5 :: Show AccountID where
  show (AccountID uuid) = "(AccountID " <> show uuid <> ")"

derive newtype instance i3 :: EncodeJson AccountID
derive newtype instance i4 :: DecodeJson AccountID

derive instance i7 :: Newtype AccountID _

--------------------------------------------------------------------------------

data Account = Account Boolean NonEmptyString

accountEnabled :: Account -> Boolean
accountEnabled (Account enabled _) = enabled

accountName :: Account -> NonEmptyString
accountName (Account _ name) = name

instance i6 :: Show Account where
  show (Account enabled name) =
    "(Account " <> show enabled <> " " <> show name <> ")"

instance i1 :: EncodeJson Account where
  encodeJson (Account enabled name) = encodeJson (enabled /\ name)

instance i2 :: DecodeJson Account where
  decodeJson = decodeJson >=> \(enabled /\ name) ->
    Account
    <$> decodeJson enabled
    <*> decodeJson name
