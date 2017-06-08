module VLA.CRM.Account.Detail
  ( initializeForm
  , initializeForm'
  ) where

import Control.Monad.Free (Free)
import Data.Validation.Semigroup (unV)
import DOM.Form (booleanField, nonEmptyStringField)
import DOM.Util (getEventTargetById, handleClick)
import Stuff
import VLA.CRM.Account (Account(..), AccountID, accountEnabled, accountName)
import VLA.CRM.Account.Algebra (Accounts, fetchAccount)

initializeForm :: (Free Accounts ~> IO) -> Maybe AccountID -> IO Unit
initializeForm foldAccounts Nothing =
  initializeForm' traceAnyA Nothing
initializeForm foldAccounts (Just accountID) =
  foldAccounts (fetchAccount accountID) >>= case _ of
    Left err -> traceAnyA err *> pure unit
    Right Nothing -> traceAnyA "not found" *> pure unit
    Right (Just account) -> initializeForm' traceAnyA (Just account)

initializeForm' :: ∀ m. MonadIOSync m => (Account -> IOSync Unit) -> Maybe Account -> m Unit
initializeForm' save account = do
  newAccount <- map unwrap \ unwrap $
    Account
    <$> booleanField "account-enabled" (accountEnabled <$> account)
    <*> nonEmptyStringField "account-name" (accountName <$> account)

  saveB <- getEventTargetById "account-save"
  handleClick saveB $
    unV traceAnyA save =<< newAccount

  pure unit
