<?php
require_once __DIR__.'/app/bootstrap.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

function out($data, $code=200){ http_response_code($code); echo json_encode($data, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES); exit; }

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') out(['status'=>'error','message'=>'Yalnızca POST desteklenir.'],405);

$auth=(string)($_SERVER['HTTP_AUTHORIZATION'] ?? '');
if (!preg_match('/^Bearer\s+(.+)$/i',$auth,$m)) out(['status'=>'error','message'=>'Yetkisiz.'],401);
$apiRaw=trim($m[1]);
$api=q("SELECT * FROM api_tokens WHERE token_hash=? AND status='active' LIMIT 1",[hash('sha256',$apiRaw)])->fetch();
if(!$api) out(['status'=>'error','message'=>'Yetkisiz.'],401);
$scopes=array_filter(array_map('trim',explode(',',(string)($api['scopes']??''))));
if(!in_array('checkin.write',$scopes,true)) out(['status'=>'error','message'=>'Bu anahtar katılım doğrulama yetkisine sahip değil.'],403);
q('UPDATE api_tokens SET last_used_at=NOW() WHERE id=?',[$api['id']]);

$body=json_decode(file_get_contents('php://input'),true);
$raw=trim((string)($body['token']??''));
if(strlen($raw)<32) out(['status'=>'invalid','message'=>'Geçersiz QR kodu.'],422);
if(!table_exists('event_checkin_tokens')) out(['status'=>'error','message'=>'QR altyapısı kurulu değil.'],503);

$hash=hash('sha256',$raw);
$t=q('SELECT * FROM event_checkin_tokens WHERE token_hash=? LIMIT 1',[$hash])->fetch();
if(!$t) out(['status'=>'invalid','message'=>'QR kodu bulunamadı.'],404);

$member=null;
if(!empty($t['member_id'])) $member=q('SELECT id,member_no,name,status FROM members WHERE id=? LIMIT 1',[(int)$t['member_id']])->fetch() ?: null;
$event=q('SELECT id,title,type,event_at,location,status FROM events WHERE id=? LIMIT 1',[(int)$t['event_id']])->fetch() ?: null;
$payload=['member'=>$member ? ['id'=>(int)$member['id'],'member_no'=>$member['member_no'],'name'=>$member['name']] : null,
          'event'=>$event ? ['id'=>(int)$event['id'],'title'=>$event['title'],'type'=>$event['type'],'event_at'=>$event['event_at'],'location'=>$event['location']] : null];

if(!empty($t['revoked_at'])) out(array_merge(['status'=>'invalid','message'=>'Bu QR kodu iptal edilmiş.'],$payload),410);
if(!empty($t['expires_at']) && strtotime($t['expires_at']) < time()) out(array_merge(['status'=>'expired','message'=>'QR kodunun süresi dolmuş.'],$payload),410);
if(!empty($t['used_at'])) out(array_merge(['status'=>'already_used','message'=>'Bu QR kodu daha önce kullanılmış.','checked_in_at'=>$t['used_at']],$payload),200);
if(!$member) out(array_merge(['status'=>'invalid','message'=>'Bu QR koduna bağlı bir üye bulunmuyor.'],$payload),422);
if(($member['status']??'')!=='active') out(array_merge(['status'=>'invalid','message'=>'Üye aktif değil.'],$payload),422);
if(!$event) out(array_merge(['status'=>'invalid','message'=>'Etkinlik bulunamadı.'],$payload),404);

try{
    db()->beginTransaction();
    $u=q('UPDATE event_checkin_tokens SET used_at=NOW() WHERE id=? AND used_at IS NULL',[(int)$t['id']]);
    if($u->rowCount()!==1){ db()->rollBack(); out(array_merge(['status'=>'already_used','message'=>'Bu QR kodu az önce başka bir cihazda okutuldu.'],$payload),200); }
    q("INSERT INTO event_attendance(event_id,member_id,response,checked_in) VALUES(?,?,'yes',1) ON DUPLICATE KEY UPDATE response='yes',checked_in=1",[(int)$t['event_id'],(int)$t['member_id']]);
    db()->commit();
    out(array_merge(['status'=>'checked_in','message'=>'Katılım kaydedildi.'],$payload),200);
}catch(Throwable $e){
    if(db()->inTransaction()) db()->rollBack();
    error_log('checkin-mobile: '.$e->getMessage());
    out(['status'=>'error','message'=>'Katılım kaydı tamamlanamadı.'],500);
}
