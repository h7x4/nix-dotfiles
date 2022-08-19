{-# LANGUAGE LambdaCase #-}

import XMonad
-- import Data.Monoid
import System.Exit

import XMonad.Hooks.ManageDocks
-- import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))

import qualified Codec.Binary.UTF8.String as UTF8
import qualified DBus                     as D
import qualified DBus.Client              as D
import XMonad.Hooks.DynamicLog

import XMonad.ManageHook

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified Data.List       as L
import Data.Maybe

import XMonad.Util.Run (spawnPipe, hPutStrLn, runProcessWithInput)
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce

import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import qualified XMonad.Layout.Magnifier as Mag

import Graphics.X11.ExtraTypes.XF86

type Color = String

background = "#272822"
foreground = "#f8f8f2"
red        = "#f92672"
green      = "#a6e22e"
yellow     = "#f4bf75"
blue       = "#66d9ef"
magenta    = "#ae81ff"
cyan       = "#a1efe4"

type TerminalCommand = String

myTerminal      = "alacritty"
-- myBrowser       = "qutebrowser"
myBrowser       = "google-chrome-stable"
myFileBrowser   = "thunar"

emacsCommand :: TerminalCommand
emacsCommand   = "emacs"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses :: Bool
myClickJustFocuses = True

myModMask :: KeyMask
myModMask = mod4Mask

myWorkspaces :: [WorkspaceId]
myWorkspaces = map (UTF8.decode . UTF8.encode) ["総","草","書","企","連","総2","総3"]

wsWeb = myWorkspaces !! 1
wsDev = myWorkspaces !! 2
wsCom = myWorkspaces !! 4

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"
myBorderWidth = 4

myScratchpads = [ NS "ncmpcpp"     spawnNC findNC layoutA
                , NS "terminal"    spawnTM findTM layoutB
                -- , NS "matrix"      spawnMX findMX layoutB
                , NS "filebrowser" spawnFB findFB layoutA
                , NS "emacs"       spawnEX findEX layoutB
                , NS "schedule"    spawnSC findSC layoutA
                , NS "help"        spawnHP findHP layoutA
                ]
  where
    spawnNC = myTerminal ++ " --title ncmpcppScratchpad -e ncmpcpp"
    spawnTM = myTerminal ++ " --class instanceClass,floatingTerminal -e tmux new-session -A -s f"
    -- spawnMX = "element"
    spawnFB = "thunar --class=floatingThunar"
    spawnEX = "emacs --name=floatingEmacs"
    spawnSC = "sxiv -N floatingSchedule ~/uni/schedule.png"
    spawnHP = "echo \"" ++ help ++ "\" | xmessage -file -"

    findNC = title =? "ncmpcppScratchpad"
    findTM = className =? "floatingTerminal"
    findSC = className =? "floatingSchedule"
    -- findMX = className =? "element"
    findFB = className =? "floatingThunar"
    findEX = className =? "floatingEmacs"
    findHP = className =? "Xmessage"

    layoutA = customFloating $ W.RationalRect l t w h
      where
        t = 0.05
        l = 0.05
        h = 0.9
        w = 0.9

    layoutB = customFloating $ W.RationalRect l t w h
      where
        l = 0.025
        t = 0.05
        h = 0.9
        w = 0.95

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
     ((modm .|. shiftMask,  xK_l ), sendMessage NextLayout)
    -- , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- , ((modm,               xK_n     ), refresh)
    , ((modm,               xK_j     ), windows W.focusDown)
    , ((modm,               xK_k     ), windows W.focusUp)
    -- , ((modm,               xK_m     ), windows W.focusMaster  )
    -- , ((modm,               xK_Return), windows W.swapMaster)
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown)
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp)
    , ((modm,               xK_h     ), sendMessage Shrink)
    , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
    , ((modm .|. shiftMask, xK_q     ), io exitSuccess)
    , ((modm              , xK_c     ), myRestartHook)
    ]

    ++

    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

     ++

    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3

    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_u, xK_i] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    ++

    -- TODO: Clean up formatting

    [
      ((modm               , xK_BackSpace), kill)
    -- , ((modm               , xK_c),         spawn myTerminal ++ " -e cfile")
    , ((modm               , xK_f),         sendMessage $ Toggle FULL)
    , ((modm               , xK_w),         namedScratchpadAction myScratchpads "emacs")
    , ((modm               , xK_e),         namedScratchpadAction myScratchpads "filebrowser")
    , ((modm               , xK_q),         namedScratchpadAction myScratchpads "ncmpcpp")
    , ((modm               , xK_minus),     namedScratchpadAction myScratchpads "schedule")
    , ((modm .|. shiftMask, xK_slash),      namedScratchpadAction myScratchpads "help")

    , ((modm               , xK_Return),    namedScratchpadAction myScratchpads "terminal")
    , ((modm               , xK_space),     namedScratchpadAction myScratchpads "terminal")
    , ((modm .|. shiftMask , xK_Return),    spawn $ myTerminal ++ " --class instanceClass,termTerminal -e tmux new-session -A -s term")
    , ((modm .|. shiftMask , xK_space ),    spawn $ myTerminal ++ " -e tmux")

    -- , ((modm               , xK_v ),        spawn "rofi -modi lpass:$HOME/.scripts/rofi/lpass//rofi-lpass -show lpass")
    , ((modm .|. shiftMask, xK_d     ), viewDropboxStatus)
    ]

termIsOpen :: X Bool
termIsOpen = isOpen
  where
    output :: X String
    output = liftIO $ runProcessWithInput "tmux" ["ls", "-F", "#{session_name}", "#{?session_attached,1,}"] ""

    isOpen = ((\(Just x) -> (x!!5) == '1')
             <$> (listToMaybe . filter (L.isInfixOf "term") . lines))
             <$> output

viewDropboxStatus :: X ()
viewDropboxStatus = spawn =<< ((++) "notify-send -t 3000 " . unpack) <$> status
  where
    status :: X String
    status = liftIO $ runProcessWithInput "python" ["$HOME/.scripts/dropbox.py", "status"] ""

    unpack :: String -> String
    unpack =  wrap "\" " "\"" . unwords . map (wrap " [" "] "). lines

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings XConfig {XMonad.modMask = modm} = M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster)

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

myLayout =
  fullscreenFull $
  avoidStruts $
  smartBorders $
  spacingRaw True (Border 0 10 10 10) True (Border 10 10 10 10) True $
  mkToggle (NOBORDERS ?? FULL ?? EOT) $
  tiled |||
  Mag.magnifier tiled |||
  Mirror tiled |||
  Full

  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100


------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "Gimp"           --> doFloat
    , className =? "QjackCtl"       --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , resource  =? "fcitx-config"   --> doFloat
    , className =? "copyq"          --> doFloat

    , className =? "firefox"        --> doShift wsWeb
    , className =? "google-chrome"  --> doShift wsWeb

    , className =? "Emacs"          --> doShift wsDev
    , className =? "Code"           --> doShift wsDev

    , className =? "discord"        --> doShift wsCom
    , className =? "Element"        --> doShift wsCom
    ] <+> namedScratchpadManageHook myScratchpads

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

mkDbusClient :: IO D.Client
mkDbusClient = do
  dbus <- D.connectSession
  D.requestName dbus (D.busName_ "org.xmonad.log") opts
  return dbus
 where
  opts = [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = D.emit dbus $ signal { D.signalBody = body }
  where
    opath  = D.objectPath_ "/org/xmonad/Log"
    iname  = D.interfaceName_ "org.xmonad.Log"
    mname  = D.memberName_ "Update"
    signal = (D.signal opath iname mname)
    body   = [D.toVariant str]

polybarHook :: D.Client -> PP
polybarHook dbus =
  let wrapper c s | s /= "NSP" = wrap ("%{F" <> c <> "}%{T2}") "%{T-}%{F-}" s
                  | otherwise  = mempty
  in  def { ppOutput          = dbusOutput dbus
          , ppCurrent         = wrapper green . wrap "[" "]"
          , ppVisible         = wrapper magenta
          , ppUrgent          = wrapper red
          , ppHidden          = wrapper blue
          , ppHiddenNoWindows = wrapper yellow
          , ppTitle           = shorten 44 . wrapper magenta
          , ppExtras          = [windowCount]
          , ppSep             = " | "
          , ppLayout          =
            wrap "%{T3}" "%{T-}" .
            (\case
              "Spacing Full"           -> "\62160"
              "Spacing Tall"           -> "\57934"
              "Spacing Magnifier Tall" -> "\61442" -- 🔍
              "Spacing Mirror Tall"    -> "\57935" -- 🪞
            )
          , ppOrder           = \(ws:l:t:ex) -> [ws,l] ++ ex ++ [t]
          }

-- myPolybarLogHook dbus = myLogHook <+> dynamicLogWithPP (polybarHook dbus)
myPolybarLogHook dbus = dynamicLogWithPP (polybarHook dbus)

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
myStartupHook :: X ()
myStartupHook = 
  spawnOnce "sxhkd &"
  -- spawnOnce "$HOME/.xmonad/setup-script/xinit.sh"

myRestartHook :: X ()
myRestartHook = do
  spawn "notify-send 'XMonad' 'Restarted XMonad/Polybar' --icon=dialog-information"
  spawn "xmonad --recompile"
  spawn "xmonad --restart"
  spawn "systemctl --user restart polybar"

------------------------------------------------------------------------

main :: IO ()
main = do
  -- xmproc <- spawnPipe "xmobar --recompile"
  dbus <- mkDbusClient
  xmonad
    $ fullscreenSupport
    $ docks def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myPolybarLogHook dbus,
        startupHook        = myStartupHook
    }

-- TODO: Generate this automatically
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
