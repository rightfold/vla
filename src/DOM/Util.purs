module DOM.Util
  ( getElementById
  , getEventTargetById
  , getInputElementById
  , handleClick
  , getChecked
  , setChecked
  , getValue
  , setValue
  ) where

import Control.Monad.Eff.Exception as Error
import Control.Monad.Except (runExcept)
import Data.Foreign (F, Foreign, toForeign)
import DOM.Event.EventTarget (addEventListener, eventListener) as DOM
import DOM.Event.Types (EventTarget, readEventTarget) as DOM
import DOM.HTML (window) as DOM
import DOM.HTML.HTMLInputElement (checked, setChecked, setValue, value) as DOM
import DOM.HTML.Types (HTMLInputElement, htmlDocumentToDocument, readHTMLInputElement) as DOM
import DOM.HTML.Window (document) as DOM
import DOM.Node.NonElementParentNode (getElementById) as DOM
import DOM.Node.Types (Element, documentToNonElementParentNode) as DOM
import Stuff

getElementById :: ∀ m e. MonadIOSync m => (Foreign -> F e) -> String -> m e
getElementById cast id = liftIOSync \ liftEff $ do
  DOM.window
  >>= DOM.document >>> map (DOM.htmlDocumentToDocument >>> DOM.documentToNonElementParentNode)
  >>= DOM.getElementById (wrap id)
  >>= maybe (Error.throwException error) pure
  >>= either (Error.throwException \ error') pure \ runExcept \ cast \ toForeign'
  where error = Error.error $ "Could not find element with ID '" <> id <> "'"
        error' = Error.error \ show
        toForeign' = toForeign :: DOM.Element -> Foreign

getEventTargetById :: ∀ m. MonadIOSync m => String -> m DOM.EventTarget
getEventTargetById = getElementById DOM.readEventTarget

getInputElementById :: ∀ m. MonadIOSync m => String -> m DOM.HTMLInputElement
getInputElementById = getElementById DOM.readHTMLInputElement

handleClick :: ∀ m. MonadIOSync m => DOM.EventTarget -> IOSync Unit -> m Unit
handleClick element action =
  let listener = DOM.eventListener \ const $ runIOSync' action
  in liftIOSync \ liftEff $ DOM.addEventListener (wrap "click") listener false element

getChecked :: ∀ m. MonadIOSync m => DOM.HTMLInputElement -> m Boolean
getChecked = liftIOSync \ liftEff \ DOM.checked

setChecked :: ∀ m. MonadIOSync m => DOM.HTMLInputElement -> Boolean -> m Unit
setChecked = liftIOSync \\ liftEff \\ flip DOM.setChecked

getValue :: ∀ m. MonadIOSync m => DOM.HTMLInputElement -> m String
getValue = liftIOSync \ liftEff \ DOM.value

setValue :: ∀ m. MonadIOSync m => DOM.HTMLInputElement -> String -> m Unit
setValue = liftIOSync \\ liftEff \\ flip DOM.setValue
