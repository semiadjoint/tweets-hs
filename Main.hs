{-# options_ghc -fno-warn-missing-import-lists #-}
{-# options_ghc -fno-warn-missing-local-signatures #-}

{-# options_ghc -Werror #-}
{-# options_ghc -Wwarn #-}

{-# language NoImplicitPrelude #-}
{-# language EmptyDataDecls #-}


module Main where

import qualified Prelude
import Protolude
import qualified Data.ByteString as S
import qualified Data.Text as T
import Data.Text.Encoding(encodeUtf8)
import Control.Lens
import Cfg
import Web.Twitter.Types
import Web.Twitter.Conduit
import Web.Twitter.Conduit.Types (TWInfo)
import qualified Web.Twitter.Conduit.Parameters as P
import Web.Twitter.Conduit.Lens
import qualified Data.Conduit as C
import Control.Monad.Trans.Resource
import qualified Data.Conduit.List as CL
import Data.ByteString.Char8 as S8
import Network.HTTP.Conduit as HTTP
import Data.Aeson()
import Data.Function((&))


main ::
  IO ()
main = do
  parseCfgFileCli cliCfg >>=
    loadCfgOrDie >>=
    start

data Samplestream

start ::
  Cfg
  -> IO ()
start cfg = do
  let
    ck = cfg ^. cfgConsumer . cfgConsumerKey
    cs = cfg ^. cfgConsumer . cfgConsumerSecret
    tk = cfg ^. cfgToken . cfgTokenKey
    ts = cfg ^. cfgToken . cfgTokenSecret
    oauth = twitterOAuth
      { oauthConsumerKey = S8.pack (T.unpack ck)
      , oauthConsumerSecret = S8.pack (T.unpack cs)
      }
    cred = Credential
      [ ("oauth_token", S8.pack (T.unpack tk))
      , ("oauth_token_secret", S8.pack (T.unpack ts))
      ]
    tgt :: APIRequest Samplestream StreamingAPI
    tgt = APIRequestGet "https://stream.twitter.com/1.1/statuses/sample.json" []
    twinfo = setCredential oauth cred def

  mgr <- newManager tlsManagerSettings
  runResourceT $ (stream twinfo mgr tgt) & process

process = (>>= (C.$$+- CL.mapM_ (liftIO . putText . show)))
