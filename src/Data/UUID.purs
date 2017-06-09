module Data.UUID
  ( UUID(..)
  , nil
  , newUUID
  , toString
  , fromString
  ) where

import Control.Monad.Eff.Random (randomInt)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Int as Int
import Data.String as String
import Database.PostgreSQL.Value (class FromSQLValue, class ToSQLValue, fromSQLValue, toSQLValue)
import Stuff
import Test.QuickCheck (class Arbitrary, arbitrary)

data UUID = UUID Int Int Int Int

nil :: UUID
nil = UUID 0 0 0 0

newUUID :: ∀ m. MonadIOSync m => m UUID
newUUID = UUID <$> random <*> random <*> random <*> random
  where random = liftIOSync \ liftEff $ randomInt bottom top

toString :: UUID -> String
toString (UUID a b c d) =
  msbs a <> lsbs a <> "-" <>
  msbs b <> "-" <> lsbs b <> "-" <>
  msbs c <> "-" <> lsbs c <>
  msbs d <> lsbs d
  where
  msbs = halfword \ (_ `zshr` 16)
  lsbs = halfword \ (_ .&. 0xFFFF)
  halfword = pad \ Int.toStringAs Int.hexadecimal
  pad s = case String.length s of
    1 -> "000" <> s
    2 -> "00" <> s
    3 -> "0" <> s
    _ -> s

fromString :: String -> Maybe UUID
fromString s =
  UUID
  <$> word 0 4
  <*> word 9 14
  <*> word 19 24
  <*> word 28 32
  where
  word msbsIdx lsbsIdx =
    (\m l -> (m `shl` 16) .|. l)
    <$> halfword msbsIdx
    <*> halfword lsbsIdx
  halfword idx =
    Int.fromStringAs Int.hexadecimal \
      String.take 4 \ String.drop idx $ s

derive instance i3 :: Eq UUID
derive instance i4 :: Ord UUID

instance i6 :: Show UUID where
  show (UUID a b c d) =
    "(UUID " <> show a <> " " <> show b <> " " <>
    show c <> " " <> show d <> ")"

instance i1 :: EncodeJson UUID where
  encodeJson = encodeJson \ toString

instance i2 :: DecodeJson UUID where
  decodeJson = fromString' <=< decodeJson
    where fromString' = maybe (Left "Value is not a UUID") Right <<< fromString

instance i7 :: ToSQLValue UUID where
  toSQLValue = toSQLValue \ toString

instance i8 :: FromSQLValue UUID where
  fromSQLValue = fromString' <=< fromSQLValue
    where fromString' = maybe (Left "Value is not a UUID") Right <<< fromString

instance i5 :: Arbitrary UUID where
  arbitrary = UUID <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary
