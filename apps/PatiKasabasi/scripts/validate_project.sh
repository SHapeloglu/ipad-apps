#!/usr/bin/env bash
set -eu

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_dir"

required_files="Makefile control Resources/Info.plist Resources/tap.wav Resources/success.wav Resources/eat.wav Resources/sleep.wav Resources/ball.wav Resources/bubble.wav Resources/laugh.wav Resources/surprise.wav main.m src/PKAppDelegate.m src/PKGameState.m src/PKCatalog.m src/PKHomeViewController.m src/PKTownMapView.m src/PKTownMapViewController.m src/PKAmbientObjectView.m src/PKActivitySceneView.m src/PKActionPropView.m src/PKThoughtBubbleView.m src/PKTownViewController.m src/PKParkViewController.m src/PKRoomPlayViewController.m src/PKWardrobeViewController.m src/PKDecorViewController.m src/PKSkillsViewController.m src/PKMiniGamesViewController.m src/PKAlbumViewController.m src/PKSoundManager.m src/PKVoiceRepeatManager.m"
for required_file in $required_files; do
    test -f "$required_file" || { echo "Eksik dosya: $required_file" >&2; exit 1; }
done

grep -q '^ARCHS = armv7$' Makefile
grep -q '^TARGET = iphone:clang:6.1:5.1$' Makefile
grep -q -- '-fno-objc-arc' Makefile
grep -q 'PatiKasabasi_RESOURCE_DIRS = Resources' Makefile
grep -q 'AudioToolbox' Makefile
grep -q 'AVFoundation' Makefile
grep -q '^Version: 0.7.0-alpha7$' control

if grep -En '(__weak|\bweak\b|\bstrong\b|@autoreleasepool|UIAlertController|UICollectionView|NSURLSession|SpriteKit|SceneKit|Metal|NSTimer|CADisplayLink|UIGraphicsImageRenderer|firstObject|setAnimationAutoreverses|SVGKit|UIWebView|animatedImageWithImages|animationImages)' src/*.[hm] main.m; then
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
assert plist["CFBundleShortVersionString"] == "0.7.0"
assert plist["CFBundleVersion"] == "7"
print("Info.plist: OK")
PY

python3 - <<'PY'
import wave
for path in ("Resources/tap.wav", "Resources/success.wav", "Resources/eat.wav", "Resources/sleep.wav", "Resources/ball.wav", "Resources/bubble.wav", "Resources/laugh.wav", "Resources/surprise.wav"):
    with wave.open(path, "rb") as audio:
        assert audio.getnchannels() == 1
        assert audio.getframerate() == 22050
        assert audio.getsampwidth() == 2
        assert audio.getnframes() <= 22050
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
grep -q '_visualScale = 0.25f' src/PKPetAvatarView.m
grep -q 'UIPanGestureRecognizer' src/PKTownMapViewController.m
grep -q 'UIPanGestureRecognizer' src/PKHomeViewController.m
grep -q 'UIPanGestureRecognizer' src/PKRoomPlayViewController.m
grep -q 'UIPanGestureRecognizer' src/PKSkillsViewController.m
grep -q 'UIPanGestureRecognizer' src/PKParkViewController.m
grep -q 'UIPanGestureRecognizer' src/PKTownViewController.m
grep -q 'setAnimationRepeatAutoreverses' src/PKTownMapViewController.m
grep -q 'removeAllAnimations' src/PKTownMapViewController.m
grep -q '@implementation PKAmbientObjectView' src/PKAmbientObjectView.m
grep -q '@implementation PKActivitySceneView' src/PKActivitySceneView.m
grep -q 'UISegmentedControl' src/PKSkillsViewController.m
grep -q 'homeTapped' src/PKSkillsViewController.m
grep -q 'highlightedItemIdentifier' src/PKRoomBackgroundView.m
grep -q 'completeNeighborRequestAtLocation' src/PKGameState.m
grep -q '@implementation PKActionPropView' src/PKActionPropView.m
grep -q '@implementation PKThoughtBubbleView' src/PKThoughtBubbleView.m
grep -q 'propPanned:' src/PKHomeViewController.m
grep -q 'beginVisualAction:' src/PKHomeViewController.m
grep -q 'consumeFoodStep' src/PKHomeViewController.m
grep -q 'rollBallBackStep' src/PKHomeViewController.m
grep -q 'runAutonomousMoment' src/PKHomeViewController.m
grep -q 'beginRoomVisualAction:' src/PKRoomPlayViewController.m
grep -q 'roomVisualSecondStep' src/PKRoomPlayViewController.m
grep -q 'frameForItemIdentifier' src/PKRoomBackgroundView.m
grep -q 'BOOL sleeping = \[_reactionIdentifier isEqualToString:@"sleep"\]' src/PKPetAvatarView.m
grep -q 'interactionZoneAtPoint' src/PKPetAvatarView.m
grep -q 'feed_favorite' src/PKPetAvatarView.m
grep -q 'feed_disliked' src/PKPetAvatarView.m
grep -q 'favoriteFoodIdentifier' src/PKPet.m
grep -q 'performFeedWithFoodIdentifier' src/PKGameState.m
grep -q 'food_fish' src/PKActionPropView.m
grep -q 'food_carrot' src/PKActionPropView.m
grep -q 'food_cookie' src/PKActionPropView.m
grep -q 'runMicroReaction' src/PKHomeViewController.m
grep -q 'finishVoiceRecording' src/PKHomeViewController.m
grep -q '@implementation PKVoiceRepeatManager' src/PKVoiceRepeatManager.m
grep -q 'AVAudioRecorder' src/PKVoiceRepeatManager.m
grep -q 'startBallGame' src/PKMiniGamesViewController.m
grep -q 'advanceBallRound' src/PKMiniGamesViewController.m
grep -q 'awardMiniGameIdentifier:@"catch"' src/PKMiniGamesViewController.m

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
test "$implementations" = "31" || {
    echo "Beklenen sınıf sayısı 31, bulunan: $implementations" >&2
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
