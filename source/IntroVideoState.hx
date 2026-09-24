package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;
import vlc.MP4Handler;

/**
 * Ce state ne sert PAS à afficher une vidéo à l'écran.
 * Il sert uniquement à "chauffer" le moteur vidéo (VLC) dès le lancement du jeu,
 * pour éviter le lag/freeze la première fois qu'une vraie vidéo est jouée en jeu
 * (ex: au lancement d'une musique).
 *
 * Principe : on charge une vidéo (assets/videos/preload.mp4) en invisible/muette,
 * on attend que le moteur signale qu'il est prêt (readyCallback), puis on la laisse
 * décoder/rendre quelques images pendant un court délai de sécurité avant de couper
 * et d'enchaîner sur le TitleState.
 *
 * IMPORTANT : il y a deux façons pour la vidéo de se terminer, et il ne faut JAMAIS
 * appeler video.finishVideo() deux fois (ça dispose deux fois le lecteur -> crash
 * "Null Object Reference" dans VlcBitmap) :
 *  - soit elle se termine TOUTE SEULE avant le délai (onVideoNaturallyFinished)
 *    -> MP4Handler a déjà tout dispose en interne, on ne touche plus à `video`.
 *  - soit c'est NOUS qui la coupons après le délai (stopVideoEarly)
 *    -> c'est nous qui appelons finishVideo() une seule fois.
 */
class IntroVideoState extends FlxState
{
	// Peut être n'importe quelle petite vidéo, idéalement le même codec/format
	// que les vidéos jouées en jeu, pour un "vrai" warm-up du moteur.
	var videoPath:String = "assets/videos/preload.mp4";

	// Délai laissé à la vidéo pour décoder/afficher quelques frames une fois prête,
	// afin de chauffer aussi le pipeline de rendu (pas juste l'ouverture du flux).
	var warmUpDelay:Float = 0.75;

	var video:MP4Handler;
	var switched:Bool = false;

	override public function create():Void
	{
		super.create();

		#if sys
		// Taille minuscule + invisible : on ne veut aucun rendu visible, juste initialiser VLC.
		video = new MP4Handler(2, 2, false);
		video.alpha = 0;

		video.readyCallback = onVideoReady;              // Le flux est ouvert : on programme le warm-up
		video.finishCallback = onVideoNaturallyFinished;  // La vidéo s'est terminée toute seule

		video.playVideo(videoPath, false, false);
		#else
		// Pas de support vidéo natif sur cette target (ex: html5), on passe directement.
		goToTitle();
		#end
	}

	function onVideoReady():Void
	{
		// Le flux est ouvert, on laisse quelques frames être décodées/rendues
		// avant de couper, pour vraiment chauffer tout le pipeline (pas juste l'ouverture).
		new FlxTimer().start(warmUpDelay, function(tmr:FlxTimer)
		{
			stopVideoEarly();
		});
	}

	// Cas 1 : le délai de warm-up est écoulé et la vidéo joue encore -> on la coupe nous-mêmes.
	function stopVideoEarly():Void
	{
		if (switched)
			return;
		switched = true;

		if (video != null)
		{
			video.finishCallback = null; // on gère la suite nous-mêmes, pas de rappel automatique
			video.finishVideo();         // dispose le lecteur (une seule fois)
		}

		goToTitle();
	}

	// Cas 2 : la vidéo est arrivée à sa fin toute seule, avant même le délai de warm-up.
	// MP4Handler a déjà appelé dispose() en interne juste avant ce callback :
	// on ne doit surtout PAS rappeler video.finishVideo() ici (double dispose = crash).
	function onVideoNaturallyFinished():Void
	{
		if (switched)
			return;
		switched = true;

		goToTitle();
	}

	function goToTitle():Void
	{
		FlxG.switchState(new TitleState());
	}
}
