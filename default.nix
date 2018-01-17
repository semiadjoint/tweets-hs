{ mkDerivation, aeson, array, async, base, base64-bytestring
, bytestring, conduit, config-ini, containers, deepseq, directory
, fast-logger, filepath, http-conduit, lens, mtl
, optparse-applicative, process, protolude, resourcet, semigroups
, stdenv, stm, streaming, text, transformers, twitter-conduit
, twitter-types, unix, unordered-containers, vector
}:
mkDerivation {
  pname = "project0";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson array async base base64-bytestring bytestring conduit
    config-ini containers deepseq directory fast-logger filepath
    http-conduit lens mtl optparse-applicative process protolude
    resourcet semigroups stm streaming text transformers
    twitter-conduit twitter-types unix unordered-containers vector
  ];
  license = stdenv.lib.licenses.bsd3;
}
