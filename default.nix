{ mkDerivation, async, base, bytestring, containers, deepseq
, directory, filepath, http-streams, io-streams, lens, mtl
, optparse-applicative, process, protolude, stdenv, stm, text
, transformers, unix, unordered-containers, vector
}:
mkDerivation {
  pname = "project0";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    async base bytestring containers deepseq directory filepath
    http-streams io-streams lens mtl optparse-applicative process
    protolude stm text transformers unix unordered-containers vector
  ];
  license = stdenv.lib.licenses.bsd3;
}
