{-# options_ghc -fno-warn-missing-import-lists #-}
{-# options_ghc -fno-warn-missing-local-signatures #-}

-- Swap the following two lines for hack mode.
{-# options_ghc -Werror #-}
{-# options_ghc -Wwarn #-}

{-# language NoImplicitPrelude #-}

module Main where

import Protolude
import qualified System.IO.Streams as Streams
import qualified Data.ByteString as S
import Network.Http.Client
import OpenSSL (withOpenSSL)

main ::
  IO ()
main = do
  ctx <- baselineContextSSL
  bracket (openConnectionSSL ctx "stream.twitter.com" 443) closeConnection fn

fn ::
  Connection
  -> IO ()
fn c = do
  let q = buildRequest1 $ do
        http GET "/1.1/statuses/sample.json"
        setAccept "text/html"

  sendRequest c q emptyBody

  receiveResponse c f
    where f p i = do
            S.putStr $ show p
            x <- Streams.read i
            S.putStr $ fromMaybe "" x
