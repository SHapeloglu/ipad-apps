#!/usr/bin/env bash
set -eu

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_dir"

required_files="Makefile control Resources/Info.plist Resources/tap.wav Resources/success.wav main.m src/PKAppDelegate.m src/PKGameState.m src/PKCatalog.m src/PKHomeViewController.m src/PKTownMapView.m src/PKTownMapViewController.m src/PKTownViewController.m src/PKParkViewController.m src/PKRoomPlayViewController.m src/PKWardrobeViewController.m src/PKDecorViewController.m src/PKSkillsViewController.m src/PKMiniGamesViewController.m src/PKAlbumViewController.m src/PKSoundManager.m"
for required_file in $required_files; do
    test -f "$required_file" || { echo "Eksik dosya: $required_file" >&2; exit 1; }
done

grep -q '^ARCHS = armv7$' Makefile
grep -q '^TARGET = iphone:clang:6.1:5.1$' Makefile
grep -q -- '-fno-objc-arc' Makefile
grep -q 'PatiKasabasi_RESOURCE_DIRS = Resources' Makefile
grep -q 'AudioToolbox' Makefile
grep -q '^Version: 0.3.0-alpha3$' control

if grep -En '(__weak|\bweak\b|\bstrong\b|@autoreleasepool|UIAlertController|UICollectionView|NSURLSession|SpriteKit|SceneKit|Metal|NSTimer|CADisplayLink|UIGraphicsImageRenderer|firstObject)' src/*.[hm] main.m; then
    echo "Legacy hedefle uyumsuz bir API veya sahiplik belirteci bulundu." >&2
    exit 1
fi

python3 - <<'PY'
import plistlib
with open("Resources/Info.plist", "rb") as handle:
    plist = plistlib.load(handle)
assert plist["CFBundleIdentifier"] == "com.olapteknoloji.patikasabasi"
assert plist["UIDeviceFamily"] == [2]
assert "armv7" in plist["UIRequiredDeviceCapabilities"]
assert plist["CFBundleShortVersionString"] == "0.3.0"
assert plist["CFBundleVersion"] == "3"
print("Info.plist: OK")
PY

python3 - <<'PY'
import wave
for path in ("Resources/tap.wav", "Resources/success.wav"):
    with wave.open(path, "rb") as audio:
        assert audio.getnchannels() == 1
        assert audio.getframerate() == 22050
        assert audio.getsampwidth() == 2
print("Ses kaynakları: OK")
PY

for feature_file in \
    src/PKTownMapView.m \
    src/PKTownMapViewController.m \
    src/PKTownViewController.m \
    src/PKParkViewController.m \
    src/PKRoomPlayViewController.m \
    src/PKWardrobeViewController.m \
    src/PKDecorViewController.m \
    src/PKSkillsViewController.m \
    src/PKMiniGamesViewController.m \
    src/PKAlbumViewController.m; do
    grep -q '^@implementation ' "$feature_file"
done

grep -q 'saveVersion' src/PKGameState.m
grep -q 'PatiKasabasiSavedGameV1' src/PKGameState.m
grep -q 'itemIdentifierAtPoint' src/PKRoomBackgroundView.m
grep -q 'equippedAccessories' src/PKPetAvatarView.m
grep -q 'completeNeighborRequestAtLocation' src/PKGameState.m

python3 - <<'PY'
from pathlib import Path

catalog = Path("src/PKCatalog.m").read_text(encoding="utf-8")
accessories = catalog.split("+ (NSDictionary *)accessoryForIdentifier:", 1)[1].split("+ (NSArray *)accessorySlots", 1)[0]
requests = catalog.split("+ (NSArray *)neighborRequests", 1)[1].split("+ (NSDictionary *)neighborRequestForDay", 1)[0]
assert accessories.count('@"id",') == 8
assert requests.count('@"id",') == 12
assert requests.count('@"luna", @"neighbor"') == 3
assert requests.count('@"zeytin", @"neighbor"') == 3
assert requests.count('@"mira", @"neighbor"') == 3
assert requests.count('@"findik", @"neighbor"') == 3
assert requests.count('@"park", @"location"') == 4
assert requests.count('@"school", @"location"') == 4
assert requests.count('@"square", @"location"') == 4
game_state = Path("src/PKGameState.m").read_text(encoding="utf-8")
assert '[NSNumber numberWithInteger:3], @"saveVersion"' in game_state
print("Kataloglar ve kayıt sürümü: OK")
PY

implementations="$(grep -h '^@implementation ' src/*.m | wc -l | tr -d ' ')"
implementation_ends="$(awk '/^@implementation /{inside=1} inside && /^@end$/{count++; inside=0} END{print count+0}' src/*.m)"
test "$implementations" = "$implementation_ends" || {
    echo "@implementation / @end sayısı uyuşmuyor." >&2
    exit 1
}

echo "Legacy yapılandırma: OK"
echo "Kaynak bütünlüğü: OK ($implementations sınıf)"

if test -n "${THEOS:-}" && test -f "$THEOS/makefiles/common.mk"; then
    echo "Theos bulundu; derleme başlatılıyor."
    make clean package
else
    echo "Theos bu ortamda yok; Objective-C cihaz derlemesi atlandı."
fi
