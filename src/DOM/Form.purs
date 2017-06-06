module DOM.Form where

import Data.Functor.Compose (bihoistCompose)
import Data.List.NonEmpty (NonEmptyList)
import Data.String.NonEmpty (NonEmptyString)
import Data.String.NonEmpty as NES
import Data.Validation.Semigroup (V, invalid)
import DOM.Util (getChecked, getInputElementById, getValue, setChecked, setValue)
import Stuff

type Validate f = Compose f (V (NonEmptyList String))

booleanField :: ∀ m m'. MonadIOSync m => MonadIOSync m' => String -> Maybe Boolean -> Compose m (Validate m') Boolean
booleanField = bihoistCompose id (wrap \ map pure) \\ booleanField'

booleanField' :: ∀ m m'. MonadIOSync m => MonadIOSync m' => String -> Maybe Boolean -> Compose m m' Boolean
booleanField' id initial = wrap do
  element <- getInputElementById id
  traverse_ (setChecked element) initial
  pure $ getChecked element

stringField' :: ∀ m m'. MonadIOSync m => MonadIOSync m' => String -> Maybe String -> Compose m m' String
stringField' id initial = wrap do
  element <- getInputElementById id
  traverse_ (setValue element) initial
  pure $ getValue element

nonEmptyStringField :: ∀ m m'. MonadIOSync m => MonadIOSync m' => String -> Maybe NonEmptyString -> Compose m (Validate m') NonEmptyString
nonEmptyStringField id initial =
  wrap \ map (wrap \ map parse) \ unwrap $
    stringField' id (NES.toString <$> initial)
  where parse = maybe (invalid (pure error)) pure \ NES.fromString
        error = id <> " must not be empty"
