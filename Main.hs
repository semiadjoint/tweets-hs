{-# options_ghc -fno-warn-missing-import-lists #-}
{-# options_ghc -fno-warn-missing-local-signatures #-}

-- Swap the following two lines for hack mode.
{-# options_ghc -Werror #-}
{-# options_ghc -Wwarn #-}

{-# language NoImplicitPrelude #-}

module Main where

import qualified Prelude
import Protolude
import qualified System.IO.Streams as Streams
import qualified Data.ByteString as S
import Network.Http.Client
import OpenSSL(withOpenSSL)
import Web.Authenticate.OAuth
import qualified Network.HTTP.Client as C
import Data.Text.Encoding(encodeUtf8)
import Control.Lens
import Control.Monad.Trans.Resource(ResourceIO())
import Cfg

main ::
  IO ()
main = do
  parseCfgFileCli cliCfg >>=
    loadCfgOrDie >>=
    start

start ::
  Cfg
  -> IO ()
start cfg = do
  let
    ck = cfg ^. cfgConsumer . cfgConsumerKey
    cs = cfg ^. cfgConsumer . cfgConsumerSecret
    tk = cfg ^. cfgToken . cfgTokenKey
    ts = cfg ^. cfgToken . cfgTokenSecret
    oa = initOauth ck cs
    cred = initCreds tk ts
    rq = undefined
    signed = signOAuth oa cred rq
  ctx <- baselineContextSSL
  bracket (openConnectionSSL ctx "stream.twitter.com" 443) closeConnection handleCxn

handleCxn ::
  Connection
  -> IO ()
handleCxn c = do
  let q = buildRequest1 $ do
        http GET "/1.1/statuses/sample.json"
        setAccept "text/html"

  sendRequest c q emptyBody

  receiveResponse c f
    where f p i = do
            S.putStr $ show p
            x <- Streams.read i
            S.putStr $ fromMaybe "" x

-- We build the oauth up as a http-client Request, then convert to our
-- Request.
convertFromHttpClient ::
  C.Request
  -> Network.Http.Client.Request
convertFromHttpClient =
  undefined

initOauth ::
  Text
  -> Text
  -> OAuth
initOauth consumerKey consumerSecret =
  def { oauthServerName = "stream.twitter.com"
      , oauthSignatureMethod = HMACSHA1
      , oauthConsumerKey = consumerKeyBs
      , oauthConsumerSecret = consumerSecretBs
      }
  where
    consumerKeyBs = encodeUtf8 consumerKey
    consumerSecretBs = encodeUtf8 consumerSecret

initCreds ::
  Text
  -> Text
  -> Credential
initCreds token tokenSecret =
  newCredential tokenBs tokenSecretBs
  where
    tokenBs = encodeUtf8 token
    tokenSecretBs = encodeUtf8 tokenSecret
