package
{
	import by.blooddy.crypto.Base64;
	
	import com.viacom.brbpl.decoder.Decoder608;
	import com.viacom.brbpl.events.CCDataEvent;
	
	import flash.display.Sprite;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.utils.ByteArray;
	
	import org.mangui.hls.HLS;
	import org.mangui.hls.event.HLSError;
	import org.mangui.hls.event.HLSEvent;
	
	[SWF(backgroundColor="0x000000")]
	public class DemoFlasHLS608CaptionPlayer extends Sprite
	{
		private var _hls:HLS;
		private var _ccDecoder:Decoder608;
		private var _videoWidth:int = 0;
		private var _videoHeight: int = 0;
		private var _stageVideo:StageVideo;
		private var _video:Video;
		private var _manifestComplete:Boolean;	
		
		public function DemoFlasHLS608CaptionPlayer()
		{
			_hls = new HLS();
			_ccDecoder  = new Decoder608();
			_ccDecoder.addEventListener(CCDataEvent.CC_DATA, onCaptionDataDecode, false, 0, true);
			_ccDecoder.addEventListener(CCDataEvent.CC_COMMAND, onCaptionCommandDecode, false, 0, true);
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailability);		
		}
		
		private function onStageVideoAvailability(event:StageVideoAvailabilityEvent):void
		{
			log("onStageVideoAvailability");
			var available : Boolean = (event.availability == StageVideoAvailability.AVAILABLE);
			_hls = new HLS();
			
			_hls.stage = stage;
			_hls.addEventListener(HLSEvent.ERROR, logHLSEvent);
			_hls.addEventListener(HLSEvent.WARNING, logHLSEvent);
			_hls.addEventListener(HLSEvent.MANIFEST_LOADED, onManifest);	
			
			var videoRect:Rectangle = new Rectangle(0,0,640,360);
			
			if (available && stage.stageVideos.length > 0) {
				_stageVideo = stage.stageVideos[0];
				_stageVideo.viewPort = videoRect;
				_stageVideo.attachNetStream(_hls.stream);
				
			} else {
				_video = new Video(videoRect.width, videoRect.height);
				_video.x = videoRect.x;
				_video.y = videoRect.y;
				addChild(_video);
				_video.smoothing = true;
				_video.attachNetStream(_hls.stream);			
			}
			
			
			stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailability);
			
			var captionInfo:Object=new Object();  
			_hls.stream.client = captionInfo; //stream is the NetStream instance  
			captionInfo.onCaptionInfo = onCaptionInfo;
			
			ExternalInterface.addCallback("load", function(url:String):void{
				log("load: " + url);					
				if(_hls){
					log("calling _hls.load: ");	
					_hls.load(url);
				}else{
					log("load failed hls not ready: " + url);
				}
			});
			
			ExternalInterface.call('window.playerReady');
			ExternalInterface.call('function(){window.playerIsReady = true;}');
		}
		
		private function onManifest(event:HLSEvent) : void {
			log("onManifest");
			_manifestComplete = true;
			_hls.stream.play();			
		}	
		
		public function onCaptionInfo(info:Object):void
		{			
			decodeCaption(Base64.decode(info.data));
		}
		
		public function decodeCaption(cap:ByteArray):void
		{			
			cap.position = 6;
			_ccDecoder.processCCData(cap);			
		}
		
		private function onCaptionDataDecode(event:CCDataEvent):void
		{					
			ExternalInterface.call("window.onCaptionData", encodeURIComponent(event.data));
		}
		
		private function onCaptionCommandDecode(event:CCDataEvent):void
		{			
			ExternalInterface.call("window.onCaptionCommand",encodeURIComponent(event.data));
		}
		
		private function logHLSEvent(event:HLSEvent):void{
			var hlsError:HLSError = event.error;
			log(hlsError.toString());
		}
		
		private function log(message:String):void {
			ExternalInterface.call('console.log', message);
		}
	}
}