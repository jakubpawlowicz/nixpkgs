{ lib, stdenv, buildGoModule, fetchFromGitHub
, pkg-config, taglib, zlib

# Disable on-the-fly transcoding,
# removing the dependency on ffmpeg.
# The server will (as of 0.11.0) gracefully fall back
# to the original file, but if transcoding is configured
# that takes a while. So best to disable all transcoding
# in the configuration if you disable transcodingSupport.
, transcodingSupport ? true, ffmpeg
, mpv }:

buildGoModule rec {
  pname = "gonic";
  version = "0.15.1";
  src = fetchFromGitHub {
    owner = "sentriz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-xq2Xk5iAKq+ttYYDNef0P3ewURmn/arTNhVc0I5gHLY=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ taglib zlib ];
  vendorSha256 = "sha256-+PUKPqW+ER7mmZXrDIc0cE4opoTxA3po3WXSeZO+Xwo=";

  # TODO(Profpatsch): write a test for transcoding support,
  # since it is prone to break
  postPatch = lib.optionalString transcodingSupport ''
    substituteInPlace \
      transcode/transcode.go \
      --replace \
        '`ffmpeg' \
        '`${lib.getBin ffmpeg}/bin/ffmpeg'
  '' + ''
    substituteInPlace \
      jukebox/jukebox.go \
      --replace \
        '"mpv"' \
        '"${lib.getBin mpv}/bin/mpv"'
  '';

  meta = {
    homepage = "https://github.com/sentriz/gonic";
    description = "Music streaming server / subsonic server API implementation";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Profpatsch ];
    platforms = lib.platforms.linux;
  };
}
