module Test.Data.UUID
  ( spec
  ) where

import Data.UUID (fromString, nil, toString)
import Stuff
import Test.QuickCheck ((===), quickCheck)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec _ Unit
spec = describe "Data.UUID" do
  describe "toString and fromString" do
    it "Formats nil" $
      toString nil `shouldEqual` "00000000-0000-0000-0000-000000000000"
    it "Parses nil" $
      fromString "00000000-0000-0000-0000-000000000000" `shouldEqual` Just nil
    it "Roundtrips" \ liftEff $
      quickCheck \uuid ->
        fromString (toString uuid) === Just uuid
