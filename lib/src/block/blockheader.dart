import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:dartsv/src/encoding/utils.dart';
import 'package:dartsv/src/exceptions.dart';
import 'package:hex/hex.dart';

class BlockHeader {

    int _version;
    List<int> _prevHash;
    List<int> _merkleRoot;
    int _time;
    int _bits;
    int _nonce;

    BlockHeader(this._version, this._prevHash, this._merkleRoot, this._time, this._bits, this._nonce);


    BlockHeader.fromHex(String blockHeaderHex) {
       _parseBuffer(HEX.decode(blockHeaderHex));
    }

    BlockHeader.fromBuffer(List<int> buffer){
       _parseBuffer(buffer);
    }

    void _parseBuffer(List<int> buffer){

        if (buffer.isEmpty) {
            throw BlockException("Header buffer can't be empty");
        }

        if (buffer.length != 80){
            throw BlockException("Header should be 80 bytes long");
        }

        ByteDataReader byteDataReader = ByteDataReader()
            ..add(buffer);

        this._version = byteDataReader.readInt32(Endian.little);
        this._prevHash = byteDataReader.read(32);
        this._merkleRoot = byteDataReader.read(32);
        this._time = byteDataReader.readUint32(Endian.little);
        this._bits = byteDataReader.readUint32(Endian.little);
        this._nonce = byteDataReader.readUint32(Endian.little);
    }

    /*
        Expected format :

          {
            "hash":"000000000b99b16390660d79fcc138d2ad0c89a0d044c4201a02bdf1f61ffa11",
            "version":2,
            "prevHash":"000000003c35b5e70b13d5b938fef4e998a977c17bea978390273b7c50a9aa4b",
            "merkleRoot":"58e6d52d1eb00470ae1ab4d5a3375c0f51382c6f249fff84e9888286974cfc97",
            "time":1371410638,
            "bits":473956288,
            "nonce":3594009557
          }
     */
    BlockHeader.fromJSONMap(LinkedHashMap<String, dynamic> map) {
        this._version = map["version"];
        this._prevHash = HEX.decode(map["prevHash"]).reversed.toList();
        this._merkleRoot = HEX.decode(map["merkleRoot"]).reversed.toList();
        this._time = map["time"];
        this._bits = map["bits"];
        this._nonce = map["nonce"];
    }

    String toHex() {
        return HEX.encode(this.buffer);
    }


    String toJSON() {
        return jsonEncode(toObject());
    }

    Object toObject() {
        return {
            "hash": HEX.encode(this.hash),
            "version": this._version,
            "prevHash": HEX.encode(this._prevHash.reversed.toList()),
            "merkleRoot": HEX.encode(this._merkleRoot.reversed.toList()),
            "time": this._time,
            "bits": this._bits,
            "nonce": this._nonce
        };
    }

    List<int> _calculateHash(List<int> buffer){
        return sha256Twice(buffer).reversed.toList();
    }

    List<int> get hash {
        return _calculateHash(this.buffer);
    }

    int get nonce => _nonce;

    int get bits => _bits;

    int get time => _time;

    int get version => _version;

    List<int> get merkleRoot => _merkleRoot;

    List<int> get prevHash => _prevHash;


    List<int> get buffer {
        ByteDataWriter writer = ByteDataWriter();

        writer.writeInt32(this._version, Endian.little);//  = byteDataReader.readInt32(Endian.little);
        writer.write(this._prevHash); // = byteDataReader.read(32);
        writer.write(this._merkleRoot); // = byteDataReader.read(32);
        writer.writeUint32(this._time, Endian.little); // = byteDataReader.readUint32(Endian.little);
        writer.writeUint32(this._bits, Endian.little); // = byteDataReader.readUint32(Endian.little);
        writer.writeUint32(this._nonce, Endian.little);// = byteDataReader.readUint32(Endian.little);

        return writer.toBytes().toList();
    }



}