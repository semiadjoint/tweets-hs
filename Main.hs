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
import qualified Data.Text as T
import Data.Text.Encoding(encodeUtf8)
import Data.Ini.Config

main ::
  IO ()
main = do
  _ <- loadCfg "/x/tweets-hs/secrets/creds.ini" cfgParser >>= (putText . T.pack . either (\s -> "Loading config failed" <> s) (\cfg -> show cfg))
  ctx <- baselineContextSSL
  bracket (openConnectionSSL ctx "stream.twitter.com" 443) closeConnection handleCxn

handleCxn ::
  Connection
  -> IO ()
handleCxn c = do
  let q = buildRequest1 $ do
        http GET "/1.1/statuses/sample.json"
        setAccept "text/html"

  let x = traceShowId q

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


-- signOAuth ::
--   ResourceIO m =>
--   OAuth              -- ^ OAuth Application
--   -> Credential         -- ^ Credential
--   -> Request m          -- ^ Original Request
--   -> ResourceT m (Request m)

data Cfg = Cfg
  { _cfgConsumer :: ConsumerCfg
  , _cfgToken :: TokenCfg
  }
  deriving(Show)
data ConsumerCfg = ConsumerCfg
  { _cfgConsumerKey :: Text
  , _cfgConsumerSecret :: Text
  }
  deriving(Show)
data TokenCfg = TokenCfg
  { _cfgTokenKey :: Text
  , _cfgTokenSecret :: Text
  }
  deriving(Show)

cfgParser :: IniParser Cfg
cfgParser = do
  cfgC <- section "CONSUMER" $ do
    ck <- field "key"
    cs <- field "secret"
    pure $ ConsumerCfg ck cs
  cfgT <- section "TOKEN" $ do
    ck <- field "key"
    cs <- field "secret"
    pure $ TokenCfg ck cs
  pure $ Cfg cfgC cfgT

loadCfg ::
  Text
  -> IniParser Cfg
  -> IO (Either Prelude.String Cfg)
loadCfg filename parser = do
  c <- readFile (T.unpack filename)
  pure $ parseIniFile c parser
