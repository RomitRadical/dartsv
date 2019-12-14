import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartsv/dartsv.dart';
import 'package:dartsv/src/block/block.dart';
import 'package:dartsv/src/block/blockheader.dart';
import 'package:dartsv/src/privatekey.dart';
import 'package:dartsv/src/script/P2PKHScriptPubkey.dart';
import 'package:dartsv/src/script/P2PKHScriptSig.dart';
import 'package:dartsv/src/script/interpreter.dart';
import 'package:dartsv/src/script/svscript.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
    var block86756 = {
        "version": 2,
        "time": 1371410638,
        "bits": 473956288,
        "nonce": 3594009557,
        "prevblockidhex": '4baaa9507c3b27908397ea7bc177a998e9f4fe38b9d5130be7b5353c00000000',
        "merkleroothex": '97fc4c97868288e984ff9f246f2c38510f5c37a3d5b41aae7004b01e2dd5e658',
        "blockheaderhex": '020000004baaa9507c3b27908397ea7bc177a998e9f4fe38b9d5130be7b5353c0000000097fc4c97868288e984ff9f246f2c38510f5c37a3d5b41aae7004b01e2dd5e658ce10be51c0ff3f1cd53b38d6',
        "blockhex": '020000004baaa9507c3b27908397ea7bc177a998e9f4fe38b9d5130be7b5353c0000000097fc4c97868288e984ff9f246f2c38510f5c37a3d5b41aae7004b01e2dd5e658ce10be51c0ff3f1cd53b38d61601000000010000000000000000000000000000000000000000000000000000000000000000ffffffff0b03e45201062f503253482fffffffff034034152a010000001976a914ee9a7590f91e04832054f0645bbf243c9fac8e2288ac0000000000000000434104ffd03de44a6e11b9917f3a29f9443283d9871c9d743ef30d5eddcd37094b64d1b3d8090496b53256786bf5c82932ec23c3b74d9f05a6f95a8b5529352656664bac0000000000000000252458e99e66e2b90bd8b2a0e2bfcce91e1f09ee7621d95e9a728ca2372d45df3ded00000000000000000100000001d6e149959b6248eee5a17c23a518e5e5e399e98f7d42a2833810f3baf1525acf000000006b4830450221009273f5d777408439a40c33ee96630a877d4f29af3f60f5c230e5254ee6f08f4302207975a64f43dc632f34479aa403b9956c484ad0c90a3c50d2e1b5037e1abb586f012103449772f2c60c2f4e1f1f74cb6c521a48f12d51ea681b64c8fc074fd8108123f6ffffffff02cb6a8233000000001976a9140487c481a671649e1db182ede98d093a335d671388ac25a21d9d000000001976a914590ea00fa3a18281d3020e7ba0c3a1d6aea663c088ac0000000001000000022a24c5dfbdb9dc5e1eb5d38dc9e8c5f8643aee53fcb0d2e44a04924b55c65c6b000000006a47304402207aa649b3ba03eeac6c6fb88e74800ca418297f62da75c58284a0c5f6cdfa96b70220324eb99fecdb0eb8bd4eec05bec0f440f4c2132c1afbaa7aaf10f31d17d8ef020121022d9055b471959ea9385bf8c92788c45d836818d86833d91331cee37d8c15ee3cffffffff1186e9edc6526a3ab463d1f0123ae38e5593364d2f80de9d8031a48274b718ab000000006c49304602210084cd799ec732e95a08c9e1ef98e99e43767b6bc4eb6af6cf65ecdf2be6bc96ab022100da1d1c450d675d383b92095c2b9949d693b82b54ac81ba219fad98f8500589ad012102b567c3f3442f71b6762404be7cc06ffd3b170d4cb98b90dab169187a07eb6786ffffffff0260dc2c00000000001976a91468340b9145127d2529dd7ebc3a4567d5579997ac88acd0ed2d00000000001976a9143770e8980281b63351861a17881cecbfaaa5c74b88ac0000000001000000020f5000a056f91d03c489d7d1558f09c7bc330af3ca8e43706d5cb08fd6c60aad010000006a47304402201068b39118afc383bb1b7de9aa8fe02cddbd8be5d29cab99d5fff23a0cef5667022020d6cfb4712fc61c13c7ca26e32028cce3d68afea7957ab4bfc5ee03bf9615d4012103b3385ed65f34e06927d8835e86103c3de352dbdece5cb704f6899886a0334662ffffffff08d4577f5634796567fb0cd50abd1886df3555f71847a1977ba5bc75195405a7010000006a47304402206728ade49cb5ec883e07d8acc6450e17b0e27b7f64c81143b4632eaded365e2e02202be3b4b723200de8c070b914d0050ead71d1418196a037f55f1a6dff4e45aee30121039e65fd2479d4edb0f3db6eecacdadcdc5ddd6d8ef518cf861466dfe1c21cc891ffffffff02d0b13700000000001976a9149a704e2c99955f50694de60f93cdd449473678aa88acc0c62d00000000001976a914dac91bdfe809346e9df5e753adaaef9336344bfc88ac000000000100000002fc85133b1e259f6deec25953bccfa75df61fd23a471553c80c043c2ea716a675000000006a47304402203da7beabc48687b746a7149679bd8982032816771b5634d1d651af59ce9fa86d0220198ea81d1a547e3493988dd94ffefff3b8fe030340886aa4ffc1b205532f0f9d012103b3385ed65f34e06927d8835e86103c3de352dbdece5cb704f6899886a0334662ffffffff04297137bc2c9f486713e4e4fab43134da153e0f8ee8e852554090d02f2605a5000000006a47304402206b729bfd4c132b673c9f1a66c645ed374338963f1e6a3b56229f72b4358f8077022023bea16c89d267313da6df152a976b36a36e1bbea738d698f0ce72ef315962df012103ba341f7dd2401a2cd51682d418fd8a12b4d0b09acb8971f0671c2211366a8531ffffffff0220753800000000001976a9144769612ee7c6e977df40a8cdfd837c85cc7a48f788acc0c62d00000000001976a914dac91bdfe809346e9df5e753adaaef9336344bfc88ac0000000001000000021cb5734a303cefa1ace87b8cc386a573f1eed8370e14c0a830fd04249b7756a6000000006a473044022059bbf19179b81fad8a15ba3dff94271d55d443da636dbaeba6ea0bb5901b8779022045417e208f41f8b37473caaf367a61ed21b31f1205605020de241e89b7ec0ca60121022d9055b471959ea9385bf8c92788c45d836818d86833d91331cee37d8c15ee3cffffffffbabb329d773e9101e127f7c1e95533fb384c79260789dc06fdf73296c9ef352d000000006b4830450220012c555e725f4eb0d767efdc07aec149c63522b06253e9d1ce6245b90c71951e022100edcce82ddd7e52a3b85bf9a4acc73a3b6df5c9b40fda36e8de09890860599ddf012102b567c3f3442f71b6762404be7cc06ffd3b170d4cb98b90dab169187a07eb6786ffffffff0210fb3000000000001976a9143770e8980281b63351861a17881cecbfaaa5c74b88ac20cf2900000000001976a914e1144ff8ca0ac143b83ada244040bfe9c8d1d63888ac0000000001000000029a494e6072106a040e279b4566f25fc35441a84f6228812142eb5515688832f5000000006b483045022100b35809ba9abcea1ec143c7cd0a27845b3f5139a6bb52757c9e24d86319f8d16c022079f8381c5287af7e6488d6a589e73caf23c487bf355ac22b7c01cf58830110bf0121023d1c9bcd771cc12b60cce62e9b8196788dd365089b70d898d60917a174e16f6affffffffec7d5d39d4db41d7d9ba0653b6c9758f20cf89a4c2e60bb27645a966889fdfd6000000006a473044022008848d34f2ca77f8bf79eb83b89ee8a24292d0c3936350a37f1522664e2e216002204ad05817044e18d0c26e89139b9fb98a21ceda2249a7cfa58f3ec420af9477c7012103af07092ed729d97d5e2ae9f8a295f1b2da268e7414ce3df9b374051d7647092bffffffff0220753800000000001976a914b1b9b659297859bd310ba8ba6f95573c635b191a88acc0c62d00000000001976a914636c549bf6035b27cf3823f5482911ebb2bce5d088ac0000000001000000028c88435add45be7b1521756b8ee3bfc51558040c3922e11facff1d6cdc7fc841000000006a47304402201bf92a99fd85e09de43b9039801f387ad6ea996d71c02185019a18cd2691d68502204500ea82873501c25c5b1476f9cd75d70b2a34a4162470e3390f89ff6a5830110121022d9055b471959ea9385bf8c92788c45d836818d86833d91331cee37d8c15ee3cffffffffbb1d138f7c9e8df06a87cd068fc303cb960c7b5670515a7759653fd3b71c6e7e000000006b4830450220277eb0e03b897cd20ac3bfa15af82ae2c1e75472ffce0482ce1594cd4536e83802210088164c46f3fc82ed3530b7552a1da6ecd2f690647485bb0fe1a706ae0f09d5b6012102718b695944b9e6f12db75e7dc7b77f023c8b9706405b62dac6e6c94dc1c7214effffffff0230c11d00000000001976a914e22f515855329b13602778a1d681295e485390b888acd0ed2d00000000001976a9141882e6174c19c4a2ac6c7d807170e76cbc75160f88ac000000000100000002948a4df70264c816b3c65bb1315bc20df2ee12baaba580818ed232a59dbe3282000000006b483045022100e96feaa777c517aa67498d51c52b7c177c18f7eb96c7ec109bcf4b7d1993245e02203d4f6dc06f4ac4ff947d81a45c9e53b12ee89e4223aa670eee2ca435157f6054012102690619097c609c03c8b82f7d289aac8a4d2fe36e5a41fc3701138deeeccd9807ffffffff8dddf5d111131865b48f2b141f635ac6c41f14adc748ea0cd6087fd69b60d573000000006b4830450220588e7eb9477043dc7b7d9f554b5db44823d9b7108a73d224af8cb24b190ebc94022100deb2fd7cfbff5f7679a38a16c18075dc9eb705850054415eba27a0f769f94e8d012102690619097c609c03c8b82f7d289aac8a4d2fe36e5a41fc3701138deeeccd9807ffffffff0220cf2900000000001976a9147ff6d70c9f71e29f3b3b77e1acb0bae8d1af12d288ac10fb3000000000001976a9141c5b740011cff8324ed10c3e8f63f6261f36613a88ac0000000001000000027624f057be29a1d4d39112006d1a1acaca84b78f5e2323c3ae587365f91b6014000000006a47304402201bfc0a95285de492ca53fd2ab89b58cdb1d9d817d7c4ade64e31bb63ccf73b7802206d4f72973c9aa804d9a5c9b749a49aec579ab7875d30c1e0b9ab8d3d7b8041ad012102926efc059307ca51862547d58b7a0c1749f0e27df6fbea550bbb291ef0a00bcbffffffffed83ae0fa16dd5602ca174f1c845be1f1c370ce483925dda6e524e6f82b93bd8000000006c4930460221008de29b6fafdadc7a1430ff453c9cb4ea96f9186c1c43b9d1f243876c4d187c5a022100f03f8a8a43c39a619c03db80bedaf9111ee817a574edf912795b3bef85024d46012102891fda8944ae461484abdc5898a94d666d8e54ed47f534218601c9a39e1058b8ffffffff02c0c62d00000000001976a914fc9c507e2cf3563c63bf9ec7b38773c2a1e1c47288acd0933c00000000001976a914736d9e4703437b3f245cda14ab4ed2d52b0a622d88ac000000000100000002a34b87af6103eac5adaba08069aca7f19c6091f6b1f4b8ca788e54970cab2039010000006b483045022049ce62033552a024ce0badb3d3c9db84af929c373b816dade2611563871e48840221009f80e97265ce861637468c98237a06df9c7482cc7c1739e1c36a8e85537c7f160121032e68cde689f248f9dcce3f1b3b607400fd1275aa3d3a821ff81dd95a3645e20fffffffffa973c9f57b44c4f70b181311ba1ab60c3f3c20663a3127d3c418b9bb3b175ef4000000006b48304502204d5decc921dff956fbcfa1a574e43e0d17b9a49ee07f294b74f854f0dd7e0160022100d49781e18670f3372961dd5799d162071e13832fa9f15197c90d7b8ab8168e8d012102690619097c609c03c8b82f7d289aac8a4d2fe36e5a41fc3701138deeeccd9807ffffffff0260dc2c00000000001976a914cc0d9d6d476efe8205891836f40e00caf2fde49288acd0ed2d00000000001976a9143770e8980281b63351861a17881cecbfaaa5c74b88ac0000000001000000026904c207207b72a9671e78f8e1284ae13b7b60c51b352142c849d338e8f3e8f1010000006a4730440220740a2107c2d9be5f621822667b9cc34566511c0e6767de900f3b46fa0852d62302207cf2fcf969e48fce7ad43880bd3a7ee5658a421a3fb718e3fd824e22e4bac6ee012102690619097c609c03c8b82f7d289aac8a4d2fe36e5a41fc3701138deeeccd9807ffffffffa3693948981b6fab5aeb9df82b1fc8e3fdbfeff8d934ce0617f4a9be699e06e7010000006c493046022100942e3ffd4522789f747b0c0d18a7228ba9f343294a34ffb0a53801b0d1626963022100eacf2ea0eef2c58e2666442bd331489dbda43adfd6d4809c2e71de38aff7fd92012103de66ea9a044ee251ba8a6dfe1d68ee1c2e17acaf5d8b568a515ff37752b6ea0effffffff0260dc2c00000000001976a914ac64ed9c139e44fd8d1d9ad28d1d08fc8a8f70f888acd0ed2d00000000001976a9143770e8980281b63351861a17881cecbfaaa5c74b88ac0000000001000000023b45e99dd007030fd8511434235b70a7d29041eb1e72d3cb2dda7d1e769ec13c000000006b48304502201c10c88a04850d9101b6cbcb51c28d9ca34f693fd918ba3c26775c5993cbdfc1022100e5d7708777b9592d709863859ce0f4d590f56acf5bb3655e119cac10d597c463012103b3385ed65f34e06927d8835e86103c3de352dbdece5cb704f6899886a0334662ffffffff87cc87cf0be7989073235f455fe6524324bfe8cba5f4ee3c2a59c46fec3bf14a010000006b48304502205cd5ea454979d705d4573d7b6f6a1bae22e5f146e0ccd14079a959a429bf69fc022100d88f05762b394621ec967546151b682f8103bed05b6d99b80adfadd626a721c5012103803aa78d28c40170231e0520fc38daa405140ed6e177c0747ce9d8d7dd6cdee4ffffffff0210dd3500000000001976a914bc1e95774ee2e36d2687714da14551132f0588b088acc0c62d00000000001976a914859819cb59368e07d4c95b5221fa4c466d66694988ac0000000001000000027848ce7fbc4f3b3e56a778607e046aa2b2cf891cdba8b61186095d4931b44c72000000006b483045022100850533f400465b01658b7dfcb05b3bae38a89344065f8321f69f7b1b2036446f0220663a629b5f2b1cf8748558ae71c8b49cda87e43347d4cbf4c84e3a79bc904a49012103b3385ed65f34e06927d8835e86103c3de352dbdece5cb704f6899886a0334662ffffffff0e33c08e14303d5660127f5d3792ca11c18321a276e71f53415af75a2319ee92010000006b483045022020d4bbbc5c300aadbc52110f7aa971d77bcf567c91d288ed6af0a98fc8f75e74022100ea84ee6d3fbeb672e92ea993d27202fc9ecd33ba7494d8b064518649fc2c17dc0121036a91343ca1c973401accb1fb902336d2a7a1b4f670ff82d9acc5c380d6a627f0ffffffff02a03c3700000000001976a9144cc35fc2651b5b3e4f22dfa9b6ebef0ca1797fb088acc0c62d00000000001976a91449452bed77744157799ba71fdb43efbd66968ad188ac0000000001000000022a6cc52c8804088ddbc164cfa01e4d9ee7e839c7a8f5d2f1b59b70a50d253f24000000006b483045022100bd72079af0ba0965d01dc6de2502ceebe38fa94fcf9850140e7ce1e5ef29d3cc02207da0e0b881594a9bc8750143dfa41ce8255e14f24784a551d3d1c4a2acecc0a2012103b3385ed65f34e06927d8835e86103c3de352dbdece5cb704f6899886a0334662ffffffff36262f4b7717eca333432cd9af776bb5ef4b29a2ea1b1cf877b49642db945c62010000006b483045022100f074c81f476f50dad72d3d07cef668532bb2b0cc772b49abf67cafd476e4e41302201e36efd9eec72b2f5ff4eac4ffbbe0598c6185b63c6ba8e03737b708e73149940121022d7e055cd28a8b7ca2613687e9b5cd4ff4a959c54d74f49c12345d1d8f78b374ffffffff02c0c62d00000000001976a914fc9c507e2cf3563c63bf9ec7b38773c2a1e1c47288ac70383900000000001976a9145ab29618ded8892f8189ca3ce81bef83d3ddda1688ac000000000100000002d724e595476277be4337bb8f39ca700b4f9df1bfb84089c4afd338e1079e9add010000006b483045022100f775b297513593c1c6e461902ab6405c4c38ce3b37d9292fe074153b8c466c29022010ded748e9e7fb1fbb263b8f466e6a1352e05ddb8842a17f712478e3d9c177040121023d1c9bcd771cc12b60cce62e9b8196788dd365089b70d898d60917a174e16f6affffffffff40fb739e2271f4aaa851dd46fcd1895ddd7a98850ef191ba3b50325c29a4ed010000006b4830450220686b1c5ecd7ea0e9078784f5ea0100035a962809fd1d0cf7a131604ecfb26f02022100ddf7b8874a375edfa4d0d7b93cfd214d0327e550add318f1a8a379cceae8dac601210363c3fa31a5453a29f6cde46c9d77698fd8276cf9f511dd6e5d079a231fea568effffffff02a01e3c00000000001976a914b0c1cda106bb5085bd9c0c9982773c7bd066fabc88acc0c62d00000000001976a914859819cb59368e07d4c95b5221fa4c466d66694988ac000000000100000002a9b95beed9491639bc0d1bb833005cf45429ef9a50505f9b91f3c7588feb87ef010000006c493046022100854bc0ee8b24e2b625798148fc505cb37464f72688456dc54b0c25c4dd564091022100c2863ab346c23157baaeb45e6d102e7354cc895ee0dd7b6ecdc77ab34bdd4d0f0121022d9055b471959ea9385bf8c92788c45d836818d86833d91331cee37d8c15ee3cffffffff8eaaf0d722fe9deffbc6e9d543f406844c93d1dd1c073d739863c314d2adf4ef000000006a47304402203f28684b208f0f4bf87ca22544e59585a7807fcd5a2ec78fc93ce915e282335502201ab05402d3a2b2914dd955971fade92dc874e6441bc2383766ec8b4c56dca27501210251a3bd043afe5cf46a40c4ce4caf3e917190583588634711507d6ef77acc438bffffffff02d0ed2d00000000001976a9141882e6174c19c4a2ac6c7d807170e76cbc75160f88ac90ab1e00000000001976a914b27f37b7cee282e7890f4f6df9b49574f35e855288ac000000000100000002fadecb6a5b1bd5f0688fc7dd049dadd956c30006e4dc57155f22c054c1550791000000006b48304502201dcb7d73d180cda9ddb192e50fcf5f0efaa5e680931f2bc25e58dd368d4b815f0221008149257f9394b01188aa84f92aec7374339076b408360767236a3af18718cddc0121032e68cde689f248f9dcce3f1b3b607400fd1275aa3d3a821ff81dd95a3645e20fffffffff569ed0585b1d5261fe5a1839e99c23d0cd3b82972526c5bb5b812ceb493facc3010000006b48304502205665ae2983ad6ec44220810a6f4c28d77dd518cc891eb9ed67503a756e97c477022100ab456b8a9c1f977623956943d8f1892c3bf84d8adefaa405606d3473f37fb8b4012102bbdf0772bbacab8eaba47d783d30fa401b08a0ecc4bccd49357171ac38791c0effffffff02d0ed2d00000000001976a9141882e6174c19c4a2ac6c7d807170e76cbc75160f88ac504b1400000000001976a914a6a0900e3c77496dc68be8ee130a21b446b8266588ac0000000001000000023d9d0df887b3621c3c884515d1a4c0a22e2bc4aa02300493cb568189847265db010000006b483045022100af41bf6edc04de96ad8b0d0e0794a7055c9677f2616fcfc1b053f87ad5c60c0f02201ef5279534263776cca80957368791a362354d7a40f3f175874b909de2d7f9a10121022d9055b471959ea9385bf8c92788c45d836818d86833d91331cee37d8c15ee3cffffffff70f6c965fcbae21ee712571b683b33e3b4d0e9c5d1fd685046db7176e3bf432e000000006b483045022033da8150f9870e045581f5894366f57345946174b43b7f8c0f9b24f7afad395c022100e3db87d42b1050ea8f2e964a13eeae86cc57e771c4dfa29f7f055c74a39be3b801210221f705f7d58ceea66122bcdc7220db0583d8ce1d7d948ed86007905268f55162ffffffff02d0ed2d00000000001976a9141882e6174c19c4a2ac6c7d807170e76cbc75160f88ac50802000000000001976a91447830d334d04acd62668904b6fab06a90742e75088ac0000000001000000022e48318fb557623da627d1c3f81ab34b99a87ce701440dfb907ad6a8691b51f2000000006c493046022100d2733fcc63dd86bc4653d268f16e467e87a7be9e1d3f45cbeccb2423b7eb1c6c022100e3963622c12dab3e9c0c76a8ef13151114cb0f17abe6c29cca2fcbac264dfc980121020ce8a0852e31812de6b8f2b2604d948cb06f8f7f404e70a19067cca01b5d0988ffffffff675f09c92aa029f3283ee9a6b8bd6f022a1ea3bdccb1d33a09416ee9389e3ecb000000006b48304502202beb8d4ff142762f12f867a1686c2a523c55ff336b8ae3992ae1292019afeaf1022100a2e7edb9ffb29628540fd02b21c84abf1cc48d70c9f6adb39550b8aff572c65a012103b3385ed65f34e06927d8835e86103c3de352dbdece5cb704f6899886a0334662ffffffff02d0933c00000000001976a914449c3ac7336a78f0c6401f51710949005d2c7ffa88acc0c62d00000000001976a914636c549bf6035b27cf3823f5482911ebb2bce5d088ac00000000010000000233232e2ce65e394a2c7e46519fae48b9b711b5152f764a4d6454bfc0552f275a000000006c493046022100928f760eaabaed51bfc4db0188c84a6a19ef34a88786f2a25d8050c8356d858d022100c1a35c67f2c21b4837eaf73e195c74eb213bdaa4650fe77da072db9f84b90d0c0121022d9055b471959ea9385bf8c92788c45d836818d86833d91331cee37d8c15ee3cfffffffff7fc20459ede0aeba4e9224ac667212ff815c651ca4feaaf40880b9f9d82413a010000006c493046022100c098dd6d9b20ed80de2d86d2c1bc9328b1c42f04b03c3767aec9d846d4538c9d0221009e32178215a499f22d8d3afe9f257159143c3d24f07371e0ef2de97d216e3b42012102078d4050a314870bd68960765015e5f884e35c60b44e23e0f2d264b73aaca477ffffffff0210fb3000000000001976a9141c5b740011cff8324ed10c3e8f63f6261f36613a88ac20cf2900000000001976a9147bdb65a92af2520836f77e5ebccc697d814149ce88ac000000000100000002dae9bc0142c15e33fe26a494d1233e80adf68b50a131f467eb13450caa56e43d000000006c493046022100ecf03f0bafb0cf6e08ac80336565bf79b6bac800f546e9f953fb14df7bf239ac022100982e27f2f0b3f8569cef126c0c54a88b002f00d570106c74f5c4b314c9609442012103b3385ed65f34e06927d8835e86103c3de352dbdece5cb704f6899886a0334662ffffffff6904c207207b72a9671e78f8e1284ae13b7b60c51b352142c849d338e8f3e8f1000000006c493046022100febc4cdfbd5073ee756c9763b0e18009893b422e13c25e8f74ca97b84c0cf73f022100a85a6c10debf45e8ad00db28fce5fcb68404e9ac4b844f0ae1d59c0ef210d714012103dc9adee9c23ca7a091b4eafc4dfef2ed07adf903dae568f345095321aa9c57e2ffffffff02a03c3700000000001976a91467a341d7fe4de6a810c182ed27a09554e0b4405d88acc0c62d00000000001976a914f7f1f64a590896dccfb869ced060f058007f388b88ac00000000'
    };

    var blockhex = block86756["blockhex"];
    List<int> blockbuf = HEX.decode(blockhex);
    var blockHeader = BlockHeader.fromBuffer(HEX.decode(block86756["blockheaderhex"]));

    var genesishex = '0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c0101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000';
    List<int> genesisBuf = HEX.decode(genesishex);
    String genesisIdHex = '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f';
    String blockOneHex = '010000006fe28c0ab6f1b372c1a6a246ae63f74f931e8365e15a089c68d6190000000000982051fd1e4ba744bbbe680e1fee14677ba1a3c3540bf7b1cdb606e857233e0e61bc6649ffff001d01e362990101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff0704ffff001d0104ffffffff0100f2052a0100000043410496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858eeac00000000';
    List<int> blockOneBuf = HEX.decode(blockOneHex);
    String blockOneId = '00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048';

    var dataJson, dataBlocks;
    List<Transaction> transactions = List<Transaction>();

    setUp(() async {
        dataJson = await File("${Directory.current.path}/test/data/blk86756-testnet.json")
            .readAsString()
            .then((contents) => jsonDecode(contents));

        dataBlocks = await File("${Directory.current.path}/test/data/bitcoind/blocks.json")
            .readAsString()
            .then((contents) => jsonDecode(contents));

        List.from(dataJson["transactions"]).forEach((tx) {
            var transaction = Transaction();
            transaction.version = tx["version"];
            transaction.nLockTime = tx["nLockTime"];
            (tx["inputs"] as List).forEach((input) {
                transaction.inputs.add(
                    TransactionInput(input["prevTxId"], input["outputIndex"], SVScript.fromHex(input["script"]), BigInt.zero, input["sequenceNumber"]));
            });

            (tx["outputs"] as List).forEach((output) {
                var txOut = TransactionOutput();
                txOut.satoshis = BigInt.from(output["satoshis"]);
                txOut.script = SVScript.fromHex(output["script"]);
                transaction.outputs.add(txOut);
            });

            //sanity check that I've constructed all transactions correctly from JSON
            expect(tx["hash"], equals(transaction.id));

            transactions.add(transaction);
        });
    });


    group('Block', ()
    {
        test('should make a new block', () {
            var b = Block.fromBuffer(blockbuf);
            expect(b.toHex(), equals(blockhex));
        });

        test('should not make an empty block', () {
            expect(() => Block.fromBuffer(<int>[]), throwsException);
        });


        group('#constructor', () {
            test('should set these known values', () {
                var block = Block(blockHeader, transactions);

                expect(block.header, isNotNull);
                expect(block.transactions, isNotNull);
            });

            test('should properly deserialize blocks', () {
                dataBlocks.forEach((block) {
                    var decodedBlock = Block.fromBuffer(HEX.decode(block["data"]));
                    expect(block["transactions"], equals(decodedBlock.transactions.length));
                });
            });
        });

        group('#fromJSON', () {
            test('should set these known values', () {
                var block = Block.fromJSONMap(dataJson);
                expect(block.header, isNotNull);
                expect(block.transactions, isNotNull);
            });
        });


        group('#toJSON', () {
            test('should recover these known values', () {
                var block = Block.fromJSONMap(dataJson);
                var b = block.toJSON();
                expect(jsonDecode(b)["header"], isNotNull);
                expect(jsonDecode(b)["transactions"], isNotNull);
            });
        });

        group('#fromHex/#toHex', () {
            test('should output/input a block hex string', () {
                var b = Block.fromHex(blockhex);
                expect(b.toHex(), equals(blockhex));
            });
        });


        group('#fromBuffer', () {
            test('should make a block from this known buffer', () {
                var block = Block.fromBuffer(blockbuf);
                expect(HEX.encode(block.buffer), equals(blockhex));
            });

            test('should instantiate from block buffer from the network', () async {
                var networkBlockHex = await File("${Directory.current.path}/test/data/test_block.json")
                    .readAsString()
                    .then((contents) => jsonDecode(contents))
                    .then((arr) => arr[0]["block"]);

                var x = Block.fromBuffer(HEX.decode(networkBlockHex));
                expect(HEX.encode(x.buffer), equals(networkBlockHex));
            });
        });


        group('#toBuffer', () {
            test('should recover a block from this known buffer', () {
                var block = Block.fromBuffer(blockbuf);
                expect(HEX.encode(block.buffer), equals(blockhex));
            });
        });


        group('#_getHash', () {
            test('should return the correct hash of the genesis block', () {
                var block = Block.fromBuffer(genesisBuf);
                var blockhash = HEX.decode(genesisIdHex);
                expect(HEX.encode(block.hash), equals(HEX.encode(blockhash)));
            });
        });

        group('#id', () {
            test('should return the correct id of the genesis block', () {
                var block = Block.fromBuffer(genesisBuf);
                expect(block.id, equals(genesisIdHex));
            });

            test('"hash" should be the same as "id"', () {
                var block = Block.fromBuffer(genesisBuf);
                expect(block.id, equals(HEX.encode(block.hash)));
            });
        });

        group('#toObject', () {
            test('should recover a block from genesis block buffer', () {
                var block = Block.fromBuffer(blockOneBuf);
                expect(block.id, equals(blockOneId));
                expect(block.toObject(), equals({
                    "header": {
                        "hash": '00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048',
                        "version": 1,
                        "prevHash": '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f',
                        "merkleRoot": '0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098',
                        "time": 1231469665,
                        "bits": 486604799,
                        "nonce": 2573394689
                    },
                    "transactions": [{
                        "hash": '0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098',
                        "version": 1,
                        "inputs": [{
                            "prevTxId": '0000000000000000000000000000000000000000000000000000000000000000',
                            "outputIndex": 4294967295,
                            "sequenceNumber": 4294967295,
                            "script": '04ffff001d0104'
                        }
                        ],
                        "outputs": [{
                            "satoshis": 5000000000,
                            "script": '410496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858eeac'
                        }
                        ],
                        "nLockTime": 0
                    }
                    ]
                }));

//                test('roundtrips correctly', () {
//                var block = Block.fromBuffer(blockOneBuf);
//                var obj = block.toObject();
//                var block2 = Block.fromObject(obj);
//                block2.toObject().should.deep.equal(block.toObject())
//                })
            });


            /* TODO: I Don't really see the need for raw block reading right now. Revisit.

        group('#fromRawBlock', () {
        test('should instantiate from a raw block binary', () {
        var x = Block.fromRawBlock(dataRawBlockBinary);
        x.header.version.should.equal(2);
        new BN(x.header.bits).toString('hex').should.equal('1c3fffc0');
        });

        test('should instantiate from raw block buffer', () {
        var x = Block.fromRawBlock(dataRawBlockBuffer);
        x.header.version.should.equal(2);
        new BN(x.header.bits).toString('hex').should.equal('1c3fffc0');
        });

        });

         */


        });
    });
}

/*

// https://test-insight.bitpay.com/block/000000000b99b16390660d79fcc138d2ad0c89a0d044c4201a02bdf1f61ffa11
var dataRawBlockBuffer = fs.readFileSync('test/data/blk86756-testnet.dat')
var dataRawBlockBinary = fs.readFileSync('test/data/blk86756-testnet.dat', 'binary')
var dataJson = fs.readFileSync('test/data/blk86756-testnet.json').toString()
var data = require('../data/blk86756-testnet')

describe('Block', function () {


  describe('#inspect', function () {
    it('should return the correct inspect of the genesis block', function () {
      var block = Block.fromBuffer(genesisbuf)
      block.inspect().should.equal('<Block ' + genesisidhex + '>')
    })
  })

  describe('#merkleRoot', function () {
    it('should describe as valid merkle root', function () {
      var x = Block.fromRawBlock(dataRawBlockBinary)
      var valid = x.validMerkleRoot()
      valid.should.equal(true)
    })

    it('should describe as invalid merkle root', function () {
      var x = Block.fromRawBlock(dataRawBlockBinary)
      x.transactions.push(new Transaction())
      var valid = x.validMerkleRoot()
      valid.should.equal(false)
    })

    it('should get a null hash merkle root', function () {
      var x = Block.fromRawBlock(dataRawBlockBinary)
      x.transactions = [] // empty the txs
      var mr = x.getMerkleRoot()
      mr.should.deep.equal(Block.Values.NULL_HASH)
    })
  })
})
*/
