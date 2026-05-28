import { Any } from '@ohos/flutter_ohos';
import { HashMap } from '@kit.ArkTS';
import { AMPSEventManager } from '../sdk/AMPSEventManager';

/**
 * Flutter ↔ OHOS 多实例协议辅助：{ instanceId, data }
 */
export class InstanceChannelHelper {
  static readonly KEY_INSTANCE_ID: string = 'instanceId';
  static readonly KEY_DATA: string = 'data';

  static instanceId(args: Any): string | undefined {
    if (args == null || args == undefined) {
      return undefined;
    }
    if (args instanceof HashMap) {
      return args.get(InstanceChannelHelper.KEY_INSTANCE_ID) as string | undefined;
    }
    if (typeof args === 'object') {
      const record = args as Record<string, Any>;
      return record[InstanceChannelHelper.KEY_INSTANCE_ID] as string | undefined;
    }
    return undefined;
  }

  static data(args: Any): Any {
    if (args == null || args == undefined) {
      return undefined;
    }
    if (args instanceof HashMap) {
      return args.get(InstanceChannelHelper.KEY_DATA);
    }
    if (typeof args === 'object') {
      const record = args as Record<string, Any>;
      return record[InstanceChannelHelper.KEY_DATA];
    }
    return undefined;
  }

  static payload(instanceId: string, data?: Any): Record<string, Any> {
    const map: Record<string, Any> = {};
    map[InstanceChannelHelper.KEY_INSTANCE_ID] = instanceId;
    if (data !== undefined) {
      map[InstanceChannelHelper.KEY_DATA] = data;
    }
    return map;
  }

  static send(method: string, instanceId: string, data?: Any): void {
    AMPSEventManager.getInstance().sendMessageToFlutter(
      method,
      InstanceChannelHelper.payload(instanceId, data),
    );
  }
}
