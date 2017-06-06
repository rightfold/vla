module VLA.CRM.Account.Detail
  ( initialize
  ) where

import DOM.Form (booleanField, nonEmptyStringField)
import DOM.Util (getEventTargetById, handleClick)
import Stuff
import VLA.CRM.Account (Account(..), accountEnabled, accountName)

initialize :: ∀ m. MonadIOSync m => Maybe Account -> m Unit
initialize account = do
  newAccount <- map unwrap \ unwrap $
    Account
    <$> booleanField "account-enabled" (accountEnabled <$> account)
    <*> nonEmptyStringField "account-name" (accountName <$> account)

  saveB <- getEventTargetById "account-save"
  handleClick saveB $
    traceAnyA =<< newAccount

  pure unit
