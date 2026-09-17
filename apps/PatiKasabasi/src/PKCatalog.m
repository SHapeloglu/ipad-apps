#import "PKCatalog.h"

@implementation PKCatalog

+ (NSArray *)itemIdentifiers {
    return [NSArray arrayWithObjects:@"bed", @"bowl", @"ball", @"plant", @"bookshelf", @"piano", @"arttable", @"rug", nil];
}

+ (NSDictionary *)itemForIdentifier:(NSString *)identifier {
    NSArray *items = [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:@"bed", @"id", @"Yumuşak Yatak", @"name", [NSNumber numberWithInteger:0], @"price", @"Uyku eylemine +5 enerji", @"effect", @"sleep", @"action", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"bowl", @"id", @"Mama Kabı", @"name", [NSNumber numberWithInteger:0], @"price", @"Besleme eylemine +5 tokluk", @"effect", @"feed", @"action", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"ball", @"id", @"Renkli Top", @"name", [NSNumber numberWithInteger:60], @"price", @"Oyun eylemine +5 eğlence", @"effect", @"play", @"action", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"plant", @"id", @"Salon Bitkisi", @"name", [NSNumber numberWithInteger:80], @"price", @"Doğa dersine +1 bonus", @"effect", @"nature", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"bookshelf", @"id", @"Kitaplık", @"name", [NSNumber numberWithInteger:120], @"price", @"Mantık dersine +1 bonus", @"effect", @"logic", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"piano", @"id", @"Mini Piyano", @"name", [NSNumber numberWithInteger:150], @"price", @"Müzik dersine +1 bonus", @"effect", @"music", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"arttable", @"id", @"Sanat Masası", @"name", [NSNumber numberWithInteger:140], @"price", @"Sanat dersine +1 bonus", @"effect", @"art", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"rug", @"id", @"Pati Halısı", @"name", [NSNumber numberWithInteger:90], @"price", @"Odayı daha neşeli yapar", @"effect", @"", @"action", nil],
        nil];
    NSUInteger index = 0;
    for (index = 0; index < [items count]; index++) {
        NSDictionary *item = [items objectAtIndex:index];
        if ([[item objectForKey:@"id"] isEqualToString:identifier]) return item;
    }
    return nil;
}

+ (NSArray *)skillIdentifiers {
    return [NSArray arrayWithObjects:@"music", @"art", @"nature", @"logic", @"social", nil];
}

+ (NSString *)skillDisplayName:(NSString *)identifier {
    if ([identifier isEqualToString:@"music"]) return @"Müzik";
    if ([identifier isEqualToString:@"art"]) return @"Sanat";
    if ([identifier isEqualToString:@"nature"]) return @"Doğa";
    if ([identifier isEqualToString:@"logic"]) return @"Mantık";
    return @"Sosyal";
}

+ (NSArray *)neighbors {
    return [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:@"luna", @"id", @"Luna", @"name", @"rabbit", @"species", @"music", @"skill", @"Şarkı söylemeyi seviyor.", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"zeytin", @"id", @"Zeytin", @"name", @"dog", @"species", @"nature", @"skill", @"Bahçeyi birlikte geziyor.", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"mira", @"id", @"Mira", @"name", @"panda", @"species", @"art", @"skill", @"Renkli resimler yapıyor.", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"findik", @"id", @"Fındık", @"name", @"cat", @"species", @"logic", @"skill", @"Bulmacalara bayılıyor.", @"detail", nil],
        nil];
}

+ (NSDictionary *)neighborForIdentifier:(NSString *)identifier {
    NSArray *neighbors = [self neighbors];
    NSUInteger index = 0;
    for (index = 0; index < [neighbors count]; index++) {
        NSDictionary *neighbor = [neighbors objectAtIndex:index];
        if ([[neighbor objectForKey:@"id"] isEqualToString:identifier]) return neighbor;
    }
    return nil;
}

+ (NSArray *)careerIdentifiers {
    return [NSArray arrayWithObjects:@"musician", @"artist", @"gardener", @"inventor", @"helper", nil];
}

+ (NSString *)careerDisplayName:(NSString *)identifier {
    if ([identifier isEqualToString:@"musician"]) return @"Müzisyen";
    if ([identifier isEqualToString:@"artist"]) return @"Ressam";
    if ([identifier isEqualToString:@"gardener"]) return @"Bahçıvan";
    if ([identifier isEqualToString:@"inventor"]) return @"Mucit";
    if ([identifier isEqualToString:@"helper"]) return @"Yardımcı";
    return @"Henüz seçilmedi";
}

+ (NSString *)careerSkillIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"musician"]) return @"music";
    if ([identifier isEqualToString:@"artist"]) return @"art";
    if ([identifier isEqualToString:@"gardener"]) return @"nature";
    if ([identifier isEqualToString:@"inventor"]) return @"logic";
    return @"social";
}

+ (NSArray *)accessoryIdentifiers {
    return [NSArray arrayWithObjects:@"redbow", @"bluecap", @"roundglasses", @"starglasses", @"greencollar", @"pinkscarf", @"stripeshirt", @"starcape", nil];
}

+ (NSDictionary *)accessoryForIdentifier:(NSString *)identifier {
    NSArray *accessories = [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:@"redbow", @"id", @"Kırmızı Kurdele", @"name", @"head", @"slot", [NSNumber numberWithInteger:0], @"price", @"Başlangıç hediyesi", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"bluecap", @"id", @"Mavi Şapka", @"name", @"head", @"slot", [NSNumber numberWithInteger:65], @"price", @"Neşeli bir sokak şapkası", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"roundglasses", @"id", @"Yuvarlak Gözlük", @"name", @"face", @"slot", [NSNumber numberWithInteger:70], @"price", @"Meraklı bakışlar için", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"starglasses", @"id", @"Yıldız Gözlük", @"name", @"face", @"slot", [NSNumber numberWithInteger:95], @"price", @"Meydan şenliklerine uygun", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"greencollar", @"id", @"Yeşil Tasma", @"name", @"neck", @"slot", [NSNumber numberWithInteger:0], @"price", @"Başlangıç hediyesi", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"pinkscarf", @"id", @"Pembe Fular", @"name", @"neck", @"slot", [NSNumber numberWithInteger:85], @"price", @"Yumuşak ve renkli", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"stripeshirt", @"id", @"Çizgili Üst", @"name", @"body", @"slot", [NSNumber numberWithInteger:110], @"price", @"Günlük oyun kıyafeti", @"detail", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"starcape", @"id", @"Yıldızlı Pelerin", @"name", @"body", @"slot", [NSNumber numberWithInteger:145], @"price", @"Özel gün kostümü", @"detail", nil],
        nil];
    NSUInteger index = 0;
    for (index = 0; index < [accessories count]; index++) {
        NSDictionary *accessory = [accessories objectAtIndex:index];
        if ([[accessory objectForKey:@"id"] isEqualToString:identifier]) return accessory;
    }
    return nil;
}

+ (NSArray *)accessorySlots {
    return [NSArray arrayWithObjects:@"head", @"face", @"neck", @"body", nil];
}

+ (NSString *)accessorySlotDisplayName:(NSString *)slotIdentifier {
    if ([slotIdentifier isEqualToString:@"head"]) return @"Baş Aksesuarı";
    if ([slotIdentifier isEqualToString:@"face"]) return @"Gözlük";
    if ([slotIdentifier isEqualToString:@"neck"]) return @"Boyun Aksesuarı";
    return @"Kostüm";
}

+ (NSArray *)neighborRequests {
    return [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:@"luna_song", @"id", @"luna", @"neighbor", @"Park Şarkısı", @"title", @"Luna parkta yeni şarkısının provasını yapmak istiyor.", @"detail", @"park", @"location", @"music", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"zeytin_flowers", @"id", @"zeytin", @"neighbor", @"Çiçeklere Su", @"title", @"Zeytin park çiçeklerini birlikte sulamak istiyor.", @"detail", @"park", @"location", @"nature", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"mira_mural", @"id", @"mira", @"neighbor", @"Meydan Resmi", @"title", @"Mira meydan panosu için renk seçmene ihtiyaç duyuyor.", @"detail", @"square", @"location", @"art", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"findik_signs", @"id", @"findik", @"neighbor", @"Yön Tabelaları", @"title", @"Fındık okul yolundaki tabelaları doğru sıraya koymak istiyor.", @"detail", @"school", @"location", @"logic", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"luna_melody", @"id", @"luna", @"neighbor", @"Şenlik Melodisi", @"title", @"Luna meydan etkinliği için kısa bir melodi seçmek istiyor.", @"detail", @"square", @"location", @"music", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"zeytin_leaves", @"id", @"zeytin", @"neighbor", @"Yaprak Albümü", @"title", @"Zeytin okul dersi için üç farklı yaprak arıyor.", @"detail", @"school", @"location", @"nature", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"mira_postcard", @"id", @"mira", @"neighbor", @"Kasaba Kartı", @"title", @"Mira okulda kasabanın kartpostalını çizmek istiyor.", @"detail", @"school", @"location", @"art", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"findik_path", @"id", @"findik", @"neighbor", @"Park Yolu", @"title", @"Fındık en kısa park yolunu bulmak için yardım istiyor.", @"detail", @"park", @"location", @"logic", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"luna_rhythm", @"id", @"luna", @"neighbor", @"Ritim Kartları", @"title", @"Luna okulun ritim kartlarını sıraya dizmek istiyor.", @"detail", @"school", @"location", @"music", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"zeytin_picnic", @"id", @"zeytin", @"neighbor", @"Piknik Köşesi", @"title", @"Zeytin meydandaki piknik köşesine bitki seçmek istiyor.", @"detail", @"square", @"location", @"nature", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"mira_kite", @"id", @"mira", @"neighbor", @"Uçurtma Deseni", @"title", @"Mira parkta uçuracağı uçurtmaya desen çizmek istiyor.", @"detail", @"park", @"location", @"art", @"skill", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"findik_lanterns", @"id", @"findik", @"neighbor", @"Fenerleri Say", @"title", @"Fındık meydandaki fenerleri gruplamak için yardım istiyor.", @"detail", @"square", @"location", @"logic", @"skill", nil],
        nil];
}

+ (NSDictionary *)neighborRequestForDay:(NSInteger)day {
    NSArray *requests = [self neighborRequests];
    if ([requests count] == 0) return nil;
    if (day < 1) day = 1;
    return [requests objectAtIndex:(NSUInteger)((day - 1) % (NSInteger)[requests count])];
}

+ (NSString *)locationDisplayName:(NSString *)identifier {
    if ([identifier isEqualToString:@"home"]) return @"Ev";
    if ([identifier isEqualToString:@"school"]) return @"Pati Okulu";
    if ([identifier isEqualToString:@"park"]) return @"Dostluk Parkı";
    return @"Kasaba Meydanı";
}

@end
