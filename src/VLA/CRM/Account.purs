module VLA.CRM.Account
  ( Account(..)
  , accountEnabled
  , accountName
  ) where

import Data.String.NonEmpty (NonEmptyString)

data Account = Account Boolean NonEmptyString

accountEnabled :: Account -> Boolean
accountEnabled (Account enabled _) = enabled

accountName :: Account -> NonEmptyString
accountName (Account _ name) = name
