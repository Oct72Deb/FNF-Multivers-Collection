package options;

import sys.FileSystem;
import flixel.FlxG;
import flixel.system.FlxSound;
import openfl.media.Sound;
import openfl.net.URLRequest;

class SafePaths {
    public static function safeInst(song:String, difficulty:Int = 2):Sound {
        var diffName = switch (difficulty) {
            case 0: "easy";
            case 1: "normal";
            default: "hard";
        }

        var customPath = 'assets/songs/$song/${song}-$diffName.ogg';
        var instPath = 'assets/songs/$song/Inst.ogg';

        if (FileSystem.exists(customPath)) {
            return new Sound(new URLRequest(customPath));
        }
        if (FileSystem.exists(instPath)) {
            return new Sound(new URLRequest(instPath));
        }

        trace('[SafePaths] Aucun fichier audio trouvé pour $song ($diffName)');
        return null;
    }
}