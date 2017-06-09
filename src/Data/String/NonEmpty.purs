module Data.String.NonEmpty
  ( NonEmptyString(..)
  , fromString
  , toString
  ) where

import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.String as String
import Stuff

data NonEmptyString = NonEmptyString Char String

fromString :: String -> Maybe NonEmptyString
fromString = map (NonEmptyString <$> _.head <*> _.tail) <<< String.uncons

toString :: NonEmptyString -> String
toString (NonEmptyString c cs) = String.singleton c <> cs

instance i3 :: Show NonEmptyString where
  show (NonEmptyString c cs) =
    "(NonEmptyString " <> show c <> " " <> show cs <> ")"

instance i1 :: EncodeJson NonEmptyString where
  encodeJson = encodeJson \ toString

instance i2 :: DecodeJson NonEmptyString where
  decodeJson = fromString' <=< decodeJson
    where fromString' = maybe (Left "Value is empty") Right <<< fromString
