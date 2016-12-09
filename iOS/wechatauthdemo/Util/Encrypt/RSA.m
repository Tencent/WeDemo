//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "RSA.h"
#import <Security/Security.h>

@interface NSString (Private)

- (SecKeyRef)getKeyRef;

@end

@interface NSData (Private)

- (NSData *)stripPublicKeyHeader;

@end

@implementation NSString (RSA)

- (NSString *)RSAEncryptWithPublicKey:(NSString *)pubKey {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *entryData = [data RSAEncryptWithPublicKey:pubKey];
    return [entryData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (SecKeyRef)getKeyRef {
    // Remove all fuck characters.
    NSString *string = [self copy];
    NSRange spos = [string rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [string rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        string = [string substringWithRange:range];
    }
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // This will be base64 encoded, decode it.
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [data stripPublicKeyHeader];
    if(!data){
        return nil;
    }
    
    NSString *tag = @"what_the_fuck_is_this";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}

@end

@implementation NSData (RSA)

- (NSData *)RSAEncryptWithPublicKey:(NSString *)pubKey {
    if (self == nil || pubKey == nil) {
        return nil;
    }
    SecKeyRef keyRef = [pubKey getKeyRef];
    if(!keyRef) {
        return nil;
    }
    
    const uint8_t *srcbuf = (const uint8_t *)[self bytes];
    size_t srclen = (size_t)[self length];
    
    size_t outlen = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    if(srclen > outlen - 11) { //PKCS1 padding
        CFRelease(keyRef);
        return nil;
    }
    void *outbuf = malloc(outlen);
    
    OSStatus status = noErr;
    status = SecKeyEncrypt(keyRef,
                           kSecPaddingOAEP,
                           srcbuf,
                           srclen,
                           outbuf,
                           &outlen
                           );
    NSData *ret = nil;
    if (status != errSecSuccess) {
        NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
    } else {
        ret = [NSData dataWithBytes:outbuf length:outlen];
    }
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

- (NSData *)stripPublicKeyHeader {
    // Skip ASN.1 public key header
    if (self == nil || [self length] <= 0)
        return nil;
    
    unsigned char *c_key = (unsigned char *)[self bytes];
    unsigned int  idx	= 0;
    
    if (c_key[idx++] != 0x30)
        return nil;
    
    if (c_key[idx] > 0x80)
        idx += c_key[idx] - 0x80 + 1;
    else
        idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    
    if (memcmp(&c_key[idx], seqiod, 15))
        return nil;
    
    idx += 15;
    
    if (c_key[idx++] != 0x03)
        return nil;
    
    if (c_key[idx] > 0x80)
        idx += c_key[idx] - 0x80 + 1;
    else
        idx++;
    
    if (c_key[idx++] != '\0')
        return nil;
    
    // Now make a new NSData from this buffer
    return [NSData dataWithBytes:&c_key[idx] length:[self length] - idx];
}

@end
