module VLA.CRM.Account.Web
  ( updateAccount
  ) where

import Hyper.Drive (Application, Request, Response, response)
import Stuff
import VLA.CRM.Account (Account)

updateAccount :: ∀ f r. Applicative f => Application f (Request Account r) (Response Unit)
updateAccount req = response <$> traceAnyA req
