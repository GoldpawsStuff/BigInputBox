# BigInputBox Change Log
All notable changes to this project will be documented in this file. Be aware that the [Unreleased] features are not yet available in the official tagged builds.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.28-Release] 2022-07-21
- Add support for WotLK beta.
- Bump to BCC client patch 2.5.4.

## [1.0.27-Release] 2022-07-09
- Bump for Classic Era client patch 1.14.3.

## [1.0.26-Release] 2022-05-31
- Bump toc to WoW client patch 9.2.5.

## [1.0.25-Release] 2022-02-23
- ToC bumps and license update.

## [1.0.24-Release] 2022-02-16
- ToC bumps and license update.

## [1.0.23-Release] 2021-12-30
### Fixed
- Separating between battleTag and bnet friends better, hoping to finally have fixed the "wrong friend name" problem.

## [1.0.22-Release] 2021-12-29
### Fixed
- The label on the input box when talking to battle.net friends was sometimes wrong after yesterday's update, using a different API call now, that seems fine so far.

## [1.0.21-Release] 2021-12-28
### Changed
- Better display of battle.net friend names. We can NOT show actual names, as this is protected information not available to the addon API. We can show the battleTag, and try to do this in a more visually pleasing manner now.

## [1.0.20-Release] 2021-11-17
- Bump Classic Era toc to client patch 1.14.1.

## [1.0.19-Release] 2021-11-05
### Fixed
- Fixed uncreated saved settings database, that sometimes would prevent repositioning.

## [1.0.18-Release] 2021-11-03
- Bump Retail toc to client patch 9.1.5.

## [1.0.17-Release] 2021-10-18
- Bump Classic Era toc to client patch 1.14.

## [1.0.16-Release] 2021-10-17
### Fixed
- The editbox will no longer bug out from the lack of pandas in the classics.

## [1.0.15-Release] 2021-09-05
### Added
- You can now choose your chat language by hovering the cursor above the editbox and clicking the language text which appears just below the box. Clicking it cycles through your available languages.

### Changes
- The editbox will now resize its width slightly based on how much you type into it.
- The contents of the editbox will no longer reset when it is closed by losing focus, like when you click somewhere else on the screen. It now requires you to either hit Esc to cancel the whole thing, or send the message with Enter. Then and only then will the box be cleared, just like the standard Blizzard chat boxes.

## [1.0.13-Release] 2021-09-01
- Bump TOC for BCC 2.5.2.

## [1.0.12-Release] 2021-07-18
### Changed
- Reply keybind should now set the editbox to the person you last received a whisper from.
- Rewhisper keybind should now set the editbox to the person you last sent a whisper to.

## [1.0.11-Release] 2021-06-29
- Bump toc version for 9.1.0.

## [1.0.10-Release] 2021-06-27
### Changed
- Moved the box into the FULLSCREEN strata, up from DIALOG.

## [1.0.9-Release] 2021-05-20
### Changed
- The number and name of numbered channels should now be visible above the input box.

## [1.0.8-Release] 2021-05-17
- Extra push needed because the bigwigs packager changed its API from using "bc" to calling it "bcc".

## [1.0.7-Release] 2021-05-12
### Fixed
- Typing unknown chat commands should no longer cause a bug.

## [1.0.6-Release] 2021-05-11
- Bump toc version for WoW BC.

## [1.0.5-Release] 2021-04-22
- Bump toc version for WoW Classic.

### Changed
- It is now possible to shift-click items to link them in the open input box.

## [1.0.4-Release] 2021-04-18
### Changed
- We no longer grab the keybind to open to a chat window with a slash `/` already entered. Since we cannot actually put that slash into the input box from our non-Blizzard addon without breaking the ability to cast spells and use items from our input box, we found it better to just NOT grab that keybind since we can't reproduce the functionaly properly.

## [1.0.3-Release] 2021-04-17
### Fixed
- Fixed wrong file ending for backdrop textures used in the input box, though it appears to have made no difference as they got loaded anyway? Still, a bug is a bug, and this is a fix!

## [1.0.2-Release] 2021-04-15
### Changed
- When whispering somebody, the input box title should now indicate who you are whispering.

### Fixed
- May or may not have fixed the issue of a double border when using with ElvUI.

## [1.0.1-Release] 2021-04-14
- First commit.
