module VLA.CRM.Account.Web
  ( fetchAccount
  , updateAccount
  ) where

import Hyper.Drive (Request, Response, response)
import Stuff
import VLA.CRM.Account (Account, AccountID)

fetchAccount :: ∀ f r. Applicative f => Request AccountID r -> f (Response (Maybe Account))
fetchAccount req = response Nothing <$ traceAnyA (unwrap req).body

updateAccount :: ∀ f r. Applicative f => Request Account r -> f (Response Unit)
updateAccount req = response <$> traceAnyA (unwrap req).body
