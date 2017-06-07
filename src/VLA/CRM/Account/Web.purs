module VLA.CRM.Account.Web
  ( fetchAccount
  , updateAccount
  ) where

import Hyper.Drive (Application, Request, Response, response)
import Stuff
import VLA.CRM.Account (Account, AccountID)

fetchAccount :: ∀ f r. Applicative f => Application f (Request AccountID r) (Response (Maybe Account))
fetchAccount req = response Nothing <$ traceAnyA (unwrap req).body

updateAccount :: ∀ f r. Applicative f => Application f (Request Account r) (Response Unit)
updateAccount req = response <$> traceAnyA (unwrap req).body
