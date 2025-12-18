import {
  AbilityAware, AbilityPluginBinding, FlutterPlugin, FlutterPluginBinding
} from '@ohos/flutter_ohos';
import { AMPSEventManager } from '../sdk/AMPSEventManager';
import { AMPSPlatformViewManager } from '../sdk/AMPSPlatformViewManager';

/** AmpsSdkPlugin **/
export default class AmpsSdkPlugin implements FlutterPlugin, AbilityAware {
  getUniqueClassName(): string {
    return "AmpsSdkPlugin"
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    AMPSEventManager.getInstance().setContext(binding.getAbility().context);
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    AMPSEventManager.getInstance().init(binding.getBinaryMessenger());
    AMPSPlatformViewManager.getInstance().init(binding);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    AMPSEventManager.getInstance().release();
  }

  onDetachedFromAbility(): void {

  }
}