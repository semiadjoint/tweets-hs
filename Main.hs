{-# language NoImplicitPrelude #-}
{-# options_ghc -W -Werror #-}

module Main where

import Protolude
import qualified System.IO.Streams as Streams
import qualified Data.ByteString as S
import Network.Http.Client

main ::
  IO ()
main = do
  c <- openConnection "www.example.com" 80

  let q = buildRequest1 $ do
        http GET "/"
        setAccept "text/html"

  sendRequest c q emptyBody

  receiveResponse c (\p i -> do
                        S.putStr $ show p
                        x <- Streams.read i
                        S.putStr $ fromMaybe "" x)
  closeConnection c
