{-# options_ghc -Wwarn #-}
{-# language NoImplicitPrelude #-}

module Histogram where

import X
import qualified Control.Concurrent.STM as STM
import qualified Data.Map.Strict as Map
import qualified Analyze as A


data Histogram =
  Histogram
  { unHistogram :: STM.TVar (Map Text Integer)
  }

