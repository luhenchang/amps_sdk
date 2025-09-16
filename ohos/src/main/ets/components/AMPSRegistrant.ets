import { FlutterAbility, FlutterEngine, FlutterManager } from '@ohos/flutter_ohos';
import { AMPSViewPlugin } from './plugin/AMPSViewPlugin';
import { AMPS } from './sdk/AMPS';
import { AMPSSplash } from './sdk/AMPSSplash';

export class AMPSRegistrant {
  static register(ability: FlutterAbility, flutterEngine: FlutterEngine) {
    new AMPS(flutterEngine, ability.context)
    ability.addPlugin(new AMPSViewPlugin())
    new AMPSSplash(flutterEngine, ability)
  }
}