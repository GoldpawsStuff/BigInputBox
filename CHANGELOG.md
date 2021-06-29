# BigInputBox Change Log
All notable changes to this project will be documented in this file. Be aware that the [Unreleased] features are not yet available in the official tagged builds.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

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
