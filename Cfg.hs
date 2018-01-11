{-# language TemplateHaskell #-}
{-# language NoImplicitPrelude #-}

{-# options_ghc -Werror #-}
{-# options_ghc -Wwarn #-}

module Cfg where

import Protolude
import qualified Prelude
import Control.Lens.TH
import Data.Ini.Config
import qualified Data.Text as T
import Options.Applicative

data ConsumerCfg = ConsumerCfg
  { _cfgConsumerKey :: Text
  , _cfgConsumerSecret :: Text
  }
makeLenses '' ConsumerCfg

data TokenCfg = TokenCfg
  { _cfgTokenKey :: Text
  , _cfgTokenSecret :: Text
  }
makeLenses '' TokenCfg

data Cfg = Cfg
  { _cfgConsumer :: ConsumerCfg
  , _cfgToken :: TokenCfg
  }
makeLenses '' Cfg

cfgParser :: IniParser Cfg
cfgParser = do
  cfgC <- section "consumer" $ do
    ck <- field "key"
    cs <- field "secret"
    pure $ ConsumerCfg ck cs
  cfgT <- section "token" $ do
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

data CliCfg = CliCfg
  { _cfgFile :: Prelude.String
  }
cliCfg ::
  Parser CliCfg
cliCfg =
  CliCfg <$> strOption (long "config-file" <> short 'f' <> help ".ini config file")



parseCfgFileCli ::
  Parser CliCfg
  -> IO Text
parseCfgFileCli cliCfg =
  fmap (T.pack . _cfgFile) (execParser opts)
  where
    opts = info (cliCfg <**> helper) (fullDesc <> progDesc "Streaming tweet stats" <> header "project0 - streaming tweets in haskell")

loadCfgOrDie ::
  Text
  -> IO Cfg
loadCfgOrDie cfgFile = do
  eCfg <- loadCfg cfgFile cfgParser
  either
    (\ s -> die $ T.pack $ "Loading config failed: " <> s)
    pure
    eCfg
