import json
import sys
from pathlib import Path

def load(path):
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except Exception as e:
        print(f"ERROR: failed to read/parse {path}: {e}")
        sys.exit(2)

p = Path('android/app/google-services.json')
if not p.exists():
    print(f"MISSING: {p} not found")
    sys.exit(1)

data = load(p)
clients = data.get('client', [])
if not clients:
    print('FAIL: no client array in google-services.json')
    sys.exit(1)

client = clients[0]
oauth = client.get('oauth_client')
if not oauth:
    print('FAIL: oauth_client is empty')
    sys.exit(1)

# find Android oauth client entries
android_oauth = [o for o in oauth if o.get('client_type') == 1]
if not android_oauth:
    print('FAIL: no Android oauth_client (client_type==1) entries found')
    sys.exit(1)

bad = False
for o in android_oauth:
    cid = o.get('client_id','')
    chash = None
    ai = o.get('android_info') or {}
    chash = ai.get('certificate_hash')
    print('Found android oauth_client:')
    print('  client_id:', cid)
    print('  certificate_hash:', chash)
    if 'REPLACE_WITH' in cid or cid.strip()=='' or (cid.endswith('.apps.googleusercontent.com') and cid.startswith('REPLACE_WITH')):
        print('  -> WARNING: client_id looks like a placeholder (REPLACE_WITH...)')
        bad = True
    if not chash or len(chash.split(':'))<4:
        print('  -> WARNING: certificate_hash missing or invalid format')
        bad = True

if bad:
    print('\nRESULT: google-services.json is NOT ready for Google Sign-In.\nFollow these steps:\n 1) In Firebase Console open your Android app and add the SHA-1 fingerprint shown above (if missing).\n 2) Download the updated google-services.json from Firebase and replace android/app/google-services.json.\n 3) Run `flutter clean && flutter pub get` then redeploy.')
    sys.exit(3)

print('\nPASS: google-services.json contains an Android oauth_client with a non-placeholder client_id and certificate hash.')
sys.exit(0)

