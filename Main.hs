{-# language NoImplicitPrelude #-}
{-# options_ghc -W -Werror -fno-warn-unused-imports #-}

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
  bracket (openConnectionSSL ctx "api.github.com" 443) closeConnection fn

fn ::
  Connection
  -> IO ()
fn c = do
  let q = buildRequest1 $ do
        http GET "/"
        setAccept "text/html"

  sendRequest c q emptyBody

  receiveResponse c f
    where f p i = do
            S.putStr $ show p
            x <- Streams.read i
            S.putStr $ fromMaybe "" x
