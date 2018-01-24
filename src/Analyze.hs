{-# options_ghc -Wwarn #-}
{-# language RankNTypes #-}
{-# language RecordWildCards #-}
{-# language NoImplicitPrelude #-}

module Analyze where

import X
import Web.Twitter.Types
import Data.Maybe(maybeToList)
import Unsafe(unsafeHead)


data Diff =
  Diff
  { totalMessageCount    :: Integer
  , emojiMessageCount    :: Integer
  , urlMessageCount      :: Integer
  , photoUrlMessageCount :: Integer
  , topEmoji             :: [(Text, Integer)]
  , topHashtags          :: [(Text, Integer)]
  , topUrlDomains        :: [(Text, Integer)]
  , topPhotoUrlDomains   :: [(Text, Integer)]
  }

data Message =
  Message
  { messageText :: Text
  }

getEmoji ::
  Message
  -> [Text]
getEmoji Message{..} =
  panic "todo: getEmoji"

computeDiff ::
  Status
  -> Diff
computeDiff s =
  Diff
  { totalMessageCount    = 1
  , emojiMessageCount    = diff enHashTags
  , urlMessageCount      = diff enURLs
  , photoUrlMessageCount = diff enMedia
  , topEmoji             = topK $ getEmoji m
  , topHashtags          = topK $ tags & (fmap $ entityBody >>> hashTagText)
  , topUrlDomains        = topK $ urls & (fmap $ entityBody >>> ueURL)
  , topPhotoUrlDomains   = topK $ medias & (fmap $ entityBody >>> meMediaURL)
  }
  where
    e = (statusEntities s)
    tags = maybeToList e >>= enHashTags
    urls = maybeToList e >>= enURLs
    medias = maybeToList e >>= enMedia
    m = Message (statusText s)

    diff ::
      (Entities -> [Entity a]) -> Integer
    diff extractor =
      let x = e >>= (extractor >>> head)
      in maybe 0 (const 1) x

    topK ::
      [Text]
      -> [(Text, Integer)]
    topK =
      group >>> fmap (\ x -> (unsafeHead x , fromIntegral $ length x))
