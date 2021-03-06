import 'package:dartsv/dartsv.dart';
import 'package:dartsv/src/exceptions.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';

void main() {
    // livenet valid
    var PKHLivenet = [
        '15vkcKf7gB23wLAnZLmbVuMiiVDc1Nm4a2',
        '1A6ut1tWnUq1SEQLMr4ttDh24wcbJ5o9TT',
        '1BpbpfLdY7oBS9gK7aDXgvMgr1DPvNhEB2',
        '1Jz2yCRd5ST1p2gUqFB5wsSQfdm3jaFfg7',
        '    1Jz2yCRd5ST1p2gUqFB5wsSQfdm3jaFfg7   \t\n'
    ];

    // livenet p2sh
    var P2SHLivenet = [
        '342ftSRCvFHfCeFFBuz4xwbeqnDw6BGUey',
        '33vt8ViH5jsr115AGkW6cEmEz9MpvJSwDk',
        '37Sp6Rv3y4kVd1nQ1JV5pfqXccHNyZm1x3',
        '3QjYXhTkvuj8qPaXHTTWb5wjXhdsLAAWVy',
        '\t3QjYXhTkvuj8qPaXHTTWb5wjXhdsLAAWVy \n \r'
    ];

    // testnet p2sh
    var P2SHTestnet = [
        '2N7FuwuUuoTBrDFdrAZ9KxBmtqMLxce9i1C',
        '2NEWDzHWwY5ZZp8CQWbB7ouNMLqCia6YRda',
        '2MxgPqX1iThW3oZVk9KoFcE5M4JpiETssVN',
        '2NB72XtkjpnATMggui83aEtPawyyKvnbX2o'
    ];

    // livenet bad checksums
    var badChecksums = [
        '15vkcKf7gB23wLAnZLmbVuMiiVDc3nq4a2',
        '1A6ut1tWnUq1SEQLMr4ttDh24wcbj4w2TT',
        '1BpbpfLdY7oBS9gK7aDXgvMgr1DpvNH3B2',
        '1Jz2yCRd5ST1p2gUqFB5wsSQfdmEJaffg7'
    ];

    // livenet non-base58
    var nonBase58 = [
        '15vkcKf7g#23wLAnZLmb\$uMiiVDc3nq4a2',
        '1A601ttWnUq1SEQLMr4ttDh24wcbj4w2TT',
        '1BpbpfLdY7oBS9gK7aIXgvMgr1DpvNH3B2',
        '1Jz2yCRdOST1p2gUqFB5wsSQfdmEJaffg7'
    ];

    // testnet valid
    var PKHTestnet = [
        'n28S35tqEMbt6vNad7A5K3mZ7vdn8dZ86X',
        'n45x3R2w2jaSC62BMa9MeJCd3TXxgvDEmm',
        'mursDVxqNQmmwWHACpM9VHwVVSfTddGsEM',
        'mtX8nPZZdJ8d3QNLRJ1oJTiEi26Sj6LQXS'
    ];

    var pubkeyhash = '3c3fa3d4adcaf8f52d5b1843975e122548269937'; //library expects this to be a byte array
    //  var buf = Buffer.concat([Buffer.from([0]), pubkeyhash])
    //  var str = '16VZnHwRhwrExfeHFHGjwrgEMq8VcYPs9r'

    test(
        'accurately parses base58 public keys to conform with bitcoind specifications', () async {
        await File("${Directory.current.path}/test/data/bitcoind/base58_keys_valid.json")
            .readAsString()
            .then((contents) => jsonDecode(contents))
            .then((jsonData) {
            List.from(jsonData).forEach((item) {
                if (!item[2]['isPrivkey']) {
                    var address = new Address(item[0]);
                    expect(address.pubkeyHash160, equals(item[1]));

                    var networkType = item[2]['isTestnet'] ? NetworkType.TEST : NetworkType.MAIN;
                    expect(address.networkTypes, contains(networkType));

                    if (item[2]['addrType'] != null) {
                        var addrType = item[2]['addrType'];
                        switch (addrType) {
                            case 'script' :
                                expect(address.addressType, equals(AddressType.SCRIPT_HASH));
                                break;
                            case 'pubkey' :
                                expect(address.addressType, equals(AddressType.PUBKEY_HASH));
                                break;
                        }
                    }
                }
            });
        });
    });

    test('throws exceptions when seeing invalid addresses', () async {
        await File("${Directory.current.path}/test/data/bitcoind/base58_keys_invalid.json")
            .readAsString()
            .then((contents) => jsonDecode(contents))
            .then((jsonData) {
            List.from(jsonData).forEach((item) {
                expect(() => Address.fromBase58(item[0]), throwsA(TypeMatcher<AddressFormatException>()));
            });
        });
    });

    test('toString() method should render actual address', () {
        var str = '13k3vneZ3yvZnc9dNWYH2RJRFsagTfAERv';
        var address = new Address(str);
        expect(address.toBase58(), equals(str));
    });

    test('invalid checksums in addresses throw exception', () {
        for (var i = 0; i < badChecksums.length; i++) {
            expect(() => new Address(badChecksums[i]), throwsA(TypeMatcher<BadChecksumException>()));
        }
    });

    test('testnet addresses are recognised and accepted', () {
        for (var i = 0; i < PKHTestnet.length; i++) {
            var address = new Address(PKHTestnet[i]);
            expect(address.networkTypes, contains(NetworkType.TEST));
        }
    });

    test('addresses with whitespaces are recognised and accepted', () {
        var ws = '  \r \t    \n 1A6ut1tWnUq1SEQLMr4ttDh24wcbJ5o9TT \t \n            \r';
        var address = new Address(ws);
        expect(address.toBase58(), equals('1A6ut1tWnUq1SEQLMr4ttDh24wcbJ5o9TT'));
    });


    test('should derive mainnet address from private key', () {
        SVPrivateKey privateKey = new SVPrivateKey();
        var publicKey = SVPublicKey.fromPrivateKey(privateKey);
        var address = publicKey.toAddress(privateKey.networkType);
        expect(address.toString()[0], equals('1'));
    });

    test('should derive testnet address from private key', () {
        var privateKey = new SVPrivateKey(networkType: NetworkType.TEST);
        var publicKey = SVPublicKey.fromPrivateKey(privateKey);
        var address = publicKey.toAddress(NetworkType.TEST);

        expect([ 'm', 'n'], contains(address.toString()[0]));
    });


    test('should make this address from a compressed pubkey', () {
        var pubkey = new SVPublicKey.fromHex('0285e9737a74c30a873f74df05124f2aa6f53042c2fc0a130d6cbd7d16b944b004');
        var address = pubkey.toAddress(NetworkType.MAIN);
        expect(address.toString(), equals('19gH5uhqY6DKrtkU66PsZPUZdzTd11Y7ke'));
    });
}


/*

'use strict'

/* jshint maxstatements: 30 */

var chai = require('chai')
var should = chai.should()
var expect = chai.expect

var bsv = require('..')
var PublicKey = bsv.PublicKey
var PrivateKey = bsv.PrivateKey
var Address = bsv.Address
var Script = bsv.Script
var Networks = bsv.Networks

var validbase58 = require('./data/bitcoind/base58_keys_valid.json')
var invalidbase58 = require('./data/bitcoind/base58_keys_invalid.json')

describe('Address', function () {


DEFER
-----
  describe('@fromHex', function () {
    it('can be instantiated from another address', function () {
      var address = Address.fromHex(buf.toString('hex'))
      var address2 = new Address({
        hashBuffer: address.hashBuffer,
        network: address.network,
        type: address.type
      })
      address.toString().should.equal(address2.toString())
    })
  })

^^^^^^

  describe('encodings', function () {

    it('should error because of incorrect format for script hash', function () {
      (function () {
        return new Address.fromScriptHash('notascript') //eslint-disable-line
      }).should.throw('Address supplied is not a buffer.')
    })

    it('should error because of incorrect type for transform buffer', function () {
      (function () {
        return Address._transformBuffer('notabuffer')
      }).should.throw('Address supplied is not a buffer.')
    })

    it('should error because of incorrect length buffer for transform buffer', function () {
      (function () {
        return Address._transformBuffer(Buffer.alloc(20))
      }).should.throw('Address buffers must be exactly 21 bytes.')
    })

    it('should error because of incorrect type for pubkey transform', function () {
      (function () {
        return Address._transformPublicKey(Buffer.alloc(20))
      }).should.throw('Address must be an instance of PublicKey.')
    })

    it('should error because of incorrect type for script transform', function () {
      (function () {
        return Address._transformScript(Buffer.alloc(20))
      }).should.throw('Invalid Argument: script must be a Script instance')
    })

    it('should error because of incorrect type for string transform', function () {
      (function () {
        return Address._transformString(Buffer.alloc(20))
      }).should.throw('data parameter supplied is not a string.')
    })

    it('should make an address from a pubkey hash buffer', function () {
      var hash = pubkeyhash // use the same hash
      var a = Address.fromPublicKeyHash(hash, 'livenet')
      a.network.should.equal(Networks.livenet)
      a.toString().should.equal(str)
      var b = Address.fromPublicKeyHash(hash, 'testnet')
      b.network.should.equal(Networks.testnet)
      b.type.should.equal('pubkeyhash')
      new Address(hash, 'livenet').toString().should.equal(str)
    })

    it('should make an address using the default network', function () {
      var hash = pubkeyhash // use the same hash
      var network = Networks.defaultNetwork
      Networks.defaultNetwork = Networks.livenet
      var a = Address.fromPublicKeyHash(hash)
      a.network.should.equal(Networks.livenet)
      // change the default
      Networks.defaultNetwork = Networks.testnet
      var b = Address.fromPublicKeyHash(hash)
      b.network.should.equal(Networks.testnet)
      // restore the default
      Networks.defaultNetwork = network
    })

    it('should throw an error for invalid length hashBuffer', function () {
      (function () {
        return Address.fromPublicKeyHash(buf)
      }).should.throw('Address hashbuffers must be exactly 20 bytes.')
    })


    it('should use the default network for pubkey', function () {
      var pubkey = new PublicKey('0285e9737a74c30a873f74df05124f2aa6f53042c2fc0a130d6cbd7d16b944b004')
      var address = Address.fromPublicKey(pubkey)
      address.network.should.equal(Networks.defaultNetwork)
    })

    it('should make this address from an uncompressed pubkey', function () {
      var pubkey = new PublicKey('0485e9737a74c30a873f74df05124f2aa6f53042c2fc0a130d6cbd7d16b944b00' +
        '4833fef26c8be4c4823754869ff4e46755b85d851077771c220e2610496a29d98')
      var a = Address.fromPublicKey(pubkey, 'livenet')
      a.toString().should.equal('16JXnhxjJUhxfyx4y6H4sFcxrgt8kQ8ewX')
      var b = new Address(pubkey, 'livenet', 'pubkeyhash')
      b.toString().should.equal('16JXnhxjJUhxfyx4y6H4sFcxrgt8kQ8ewX')
    })

    it('should classify from a custom network', function () {
      var custom = {
        name: 'customnetwork',
        pubkeyhash: 10,
        privatekey: 0x1e,
        scripthash: 15,
        xpubkey: 0x02e8de8f,
        xprivkey: 0x02e8da54,
        networkMagic: 0x0c110907,
        port: 7333
      }
      Networks.add(custom)
      var addressString = '57gZdnwcQHLirKLwDHcFiWLq9jTZwRaxaE'
      var network = Networks.get('customnetwork')
      var address = Address.fromString(addressString)
      address.type.should.equal(Address.PayToPublicKeyHash)
      address.network.should.equal(network)
      Networks.remove(network)
    })

    describe('from a script', function () {
      it('should fail to build address from a non p2sh,p2pkh script', function () {
        var s = new Script('OP_CHECKMULTISIG');
        (function () {
          return new Address(s)
        }).should.throw('needs to be p2pkh in, p2pkh out, p2sh in, or p2sh out')
      })
      it('should make this address from a p2pkh output script', function () {
        var s = new Script('OP_DUP OP_HASH160 20 ' +
          '0xc8e11b0eb0d2ad5362d894f048908341fa61b6e1 OP_EQUALVERIFY OP_CHECKSIG')
        var a = Address.fromScript(s, 'livenet')
        a.toString().should.equal('1KK9oz4bFH8c1t6LmighHaoSEGx3P3FEmc')
        var b = new Address(s, 'livenet')
        b.toString().should.equal('1KK9oz4bFH8c1t6LmighHaoSEGx3P3FEmc')
      })

      it('should make this address from a p2sh input script', function () {
        var s = Script.fromString('OP_HASH160 20 0xa6ed4af315271e657ee307828f54a4365fa5d20f OP_EQUAL')
        var a = Address.fromScript(s, 'livenet')
        a.toString().should.equal('3GueMn6ruWVfQTN4XKBGEbCbGLwRSUhfnS')
        var b = new Address(s, 'livenet')
        b.toString().should.equal('3GueMn6ruWVfQTN4XKBGEbCbGLwRSUhfnS')
      })

      it('returns the same address if the script is a pay to public key hash out', function () {
        var address = '16JXnhxjJUhxfyx4y6H4sFcxrgt8kQ8ewX'
        var script = Script.buildPublicKeyHashOut(new Address(address))
        Address(script, Networks.livenet).toString().should.equal(address)
      })
      it('returns the same address if the script is a pay to script hash out', function () {
        var address = '3BYmEwgV2vANrmfRymr1mFnHXgLjD6gAWm'
        var script = Script.buildScriptHashOut(new Address(address))
        Address(script, Networks.livenet).toString().should.equal(address)
      })
    })

    it('should derive from this known address string livenet', function () {
      var address = new Address(str)
      var buffer = address.toBuffer()
      var slice = buffer.slice(1)
      var sliceString = slice.toString('hex')
      sliceString.should.equal(pubkeyhash.toString('hex'))
    })

    it('should derive from this known address string testnet', function () {
      var a = new Address(PKHTestnet[0], 'testnet')
      var b = new Address(a.toString())
      b.toString().should.equal(PKHTestnet[0])
      b.network.should.equal(Networks.testnet)
    })

    it('should derive from this known address string livenet scripthash', function () {
      var a = new Address(P2SHLivenet[0], 'livenet', 'scripthash')
      var b = new Address(a.toString())
      b.toString().should.equal(P2SHLivenet[0])
    })

    it('should derive from this known address string testnet scripthash', function () {
      var address = new Address(P2SHTestnet[0], 'testnet', 'scripthash')
      address = new Address(address.toString())
      address.toString().should.equal(P2SHTestnet[0])
    })
  })

  describe('#toBuffer', function () {
    it('3c3fa3d4adcaf8f52d5b1843975e122548269937 corresponds to hash 16VZnHwRhwrExfeHFHGjwrgEMq8VcYPs9r', function () {
      var address = new Address(str)
      address.toBuffer().slice(1).toString('hex').should.equal(pubkeyhash.toString('hex'))
    })
  })

  describe('#toHex', function () {
    it('3c3fa3d4adcaf8f52d5b1843975e122548269937 corresponds to hash 16VZnHwRhwrExfeHFHGjwrgEMq8VcYPs9r', function () {
      var address = new Address(str)
      address.toHex().slice(2).should.equal(pubkeyhash.toString('hex'))
    })
  })

  describe('#object', function () {
    it('roundtrip to-from-to', function () {
      var obj = new Address(str).toObject()
      var address = Address.fromObject(obj)
      address.toString().should.equal(str)
    })

    it('will fail with invalid state', function () {
      expect(function () {
        return Address.fromObject('¹')
      }).to.throw(bsv.errors.InvalidState)
    })
  })

  describe('#toString', function () {
    it('livenet pubkeyhash address', function () {
      var address = new Address(str)
      address.toString().should.equal(str)
    })

    it('scripthash address', function () {
      var address = new Address(P2SHLivenet[0])
      address.toString().should.equal(P2SHLivenet[0])
    })

    it('testnet scripthash address', function () {
      var address = new Address(P2SHTestnet[0])
      address.toString().should.equal(P2SHTestnet[0])
    })

    it('testnet pubkeyhash address', function () {
      var address = new Address(PKHTestnet[0])
      address.toString().should.equal(PKHTestnet[0])
    })
  })

  describe('#inspect', function () {
    it('should output formatted output correctly', function () {
      var address = new Address(str)
      var output = '<Address: 16VZnHwRhwrExfeHFHGjwrgEMq8VcYPs9r, type: pubkeyhash, network: livenet>'
      address.inspect().should.equal(output)
    })
  })

  describe('questions about the address', function () {
    it('should detect a P2SH address', function () {
      new Address(P2SHLivenet[0]).isPayToScriptHash().should.equal(true)
      new Address(P2SHLivenet[0]).isPayToPublicKeyHash().should.equal(false)
      new Address(P2SHTestnet[0]).isPayToScriptHash().should.equal(true)
      new Address(P2SHTestnet[0]).isPayToPublicKeyHash().should.equal(false)
    })
    it('should detect a Pay To PubkeyHash address', function () {
      new Address(PKHLivenet[0]).isPayToPublicKeyHash().should.equal(true)
      new Address(PKHLivenet[0]).isPayToScriptHash().should.equal(false)
      new Address(PKHTestnet[0]).isPayToPublicKeyHash().should.equal(true)
      new Address(PKHTestnet[0]).isPayToScriptHash().should.equal(false)
    })
  })

  it('throws an error if it couldn\'t instantiate', function () {
    expect(function () {
      return new Address(1)
    }).to.throw(TypeError)
  })
  it('can roundtrip from/to a object', function () {
    var address = new Address(P2SHLivenet[0])
    expect(new Address(address.toObject()).toString()).to.equal(P2SHLivenet[0])
  })

  it('will use the default network for an object', function () {
    var obj = {
      hash: '19a7d869032368fd1f1e26e5e73a4ad0e474960e',
      type: 'scripthash'
    }
    var address = new Address(obj)
    address.network.should.equal(Networks.defaultNetwork)
  })

  describe('creating a P2SH address from public keys', function () {
    var public1 = '02da5798ed0c055e31339eb9b5cef0d3c0ccdec84a62e2e255eb5c006d4f3e7f5b'
    var public2 = '0272073bf0287c4469a2a011567361d42529cd1a72ab0d86aa104ecc89342ffeb0'
    var public3 = '02738a516a78355db138e8119e58934864ce222c553a5407cf92b9c1527e03c1a2'
    var publics = [public1, public2, public3]

    it('can create an address from a set of public keys', function () {
      var address = Address.createMultisig(publics, 2, Networks.livenet)
      address.toString().should.equal('3FtqPRirhPvrf7mVUSkygyZ5UuoAYrTW3y')
      address = new Address(publics, 2, Networks.livenet)
      address.toString().should.equal('3FtqPRirhPvrf7mVUSkygyZ5UuoAYrTW3y')
    })

    it('works on testnet also', function () {
      var address = Address.createMultisig(publics, 2, Networks.testnet)
      address.toString().should.equal('2N7T3TAetJrSCruQ39aNrJvYLhG1LJosujf')
    })

    it('can also be created by Address.createMultisig', function () {
      var address = Address.createMultisig(publics, 2)
      var address2 = Address.createMultisig(publics, 2)
      address.toString().should.equal(address2.toString())
    })

    it('fails if invalid array is provided', function () {
      expect(function () {
        return Address.createMultisig([], 3, 'testnet')
      }).to.throw('Number of required signatures must be less than or equal to the number of public keys')
    })
  })

})
 */