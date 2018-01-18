{-# options_ghc -fno-warn-missing-import-lists #-}
{-# options_ghc -fno-warn-missing-local-signatures #-}

{-# options_ghc -Werror #-}
{-# options_ghc -Wwarn #-}

{-# language NoImplicitPrelude #-}
{-# language EmptyDataDecls #-}
{-# language RecordWildCards #-}


module Main where

import qualified Prelude
import           Protolude
import qualified Data.ByteString as S
import qualified Data.Text as T
import           Data.Text.Encoding (encodeUtf8)
import           Control.Lens
import           Cfg
import           Web.Twitter.Types
import           Web.Twitter.Conduit
import qualified Web.Twitter.Conduit.Parameters as P
import           Web.Twitter.Conduit.Lens
import qualified Data.Conduit as C
import           Control.Monad.Trans.Resource
import qualified Data.Conduit.List as CL
import           Data.ByteString.Char8 as S8
import           Network.HTTP.Conduit as HTTP
import           Data.Aeson ()
import           System.Log.FastLogger
import qualified System.IO
import qualified System.Metrics.Prometheus.Http.Scrape as Metrics
import qualified System.Metrics.Prometheus.Concurrent.RegistryT as Metrics
import qualified System.Metrics.Prometheus.Concurrent.Registry as Metrics hiding(registerCounter)
import qualified System.Metrics.Prometheus.Metric.Counter as Metrics

data Samplestream

main ::
  IO ()
main = do
  cfg <- loadCfgOrDie =<< parseCfgFileCli cliCfg
  withFastLogger (LogStdout 1) (start cfg)

start ::
  Cfg
  -> FastLogger
  -> IO ()
start cfg log = do
  System.IO.hSetBuffering System.IO.stdin System.IO.NoBuffering
  metrics <- Metrics.runRegistryT $ do
    m <- initMetrics
    liftIO $ log "initialized metrics"
    Metrics.serveHttpTextMetricsT 5775 ["metrics"]
    liftIO $ log "initialized metrics server"
    pure m
  Metrics.inc $ eventsCounter metrics
  putText $ "kill me"
  let
    twinfo = twInfo cfg
    tgt :: APIRequest Samplestream StreamingAPI
    tgt = APIRequestGet "https://stream.twitter.com/1.1/statuses/sample.json" []
  mgr <- newManager tlsManagerSettings
  runResourceT $ (stream twinfo mgr tgt) & (process log)
  where
    process log = (>>= (C.$$+- CL.mapM_ (liftIO . log . toLogStr . T.pack . show)))

data MessageSourceMetrics =
  MessageSourceMetrics
  { eventsCounter :: Metrics.Counter
  }


initMetrics :: Metrics.RegistryT IO MessageSourceMetrics
initMetrics = Metrics.runRegistryT $ do
  eventsCounter <- lift $ Metrics.registerCounter "events_total" mempty
  pure $ MessageSourceMetrics {..}
