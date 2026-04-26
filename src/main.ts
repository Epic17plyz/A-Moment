import * as rm from "https://deno.land/x/remapper@4.2.3/src/mod.ts"
import * as bundleInfo from '../bundleinfo.json' with { type: 'json' }

const pipeline = await rm.createPipeline({ bundleInfo })

const bundle = rm.loadBundle(bundleInfo)
const materials = bundle.materials
const prefabs = bundle.prefabs

// ----------- { SCRIPT } -----------

async function doMap(file: rm.DIFFICULTY_NAME) {
    const map = await rm.readDifficultyV3(pipeline, file)
    
    //Map Setup
    map.difficultyInfo.settingsSetter.chroma.disableChromaEvents = false
    map.difficultyInfo.settingsSetter.chroma.disableEnvironmentEnhancements = false
    map.difficultyInfo.settingsSetter.playerOptions.hideNoteSpawnEffect = true
    map.difficultyInfo.settingsSetter.playerOptions.noTextsAndHuds = true
    map.difficultyInfo.settingsSetter.playerOptions.noteJumpDurationTypeSettings = 'Dynamic'
    map.difficultyInfo.settingsSetter.playerOptions.noteJumpStartBeatOffset = 0
    map.difficultyInfo.settingsSetter.graphics.mainEffectGraphicsSettings = 'On'

    map.require(rm.MODS.CHROMA)
    map.require(rm.MODS.NOODLE_EXTENSIONS)
    map.require(rm.MODS.VIVIFY)

    rm.environmentRemoval(map, [
        'Environment',
        'GameCore'
    ])

    //Vivify
    const prefab0 = prefabs["sun rise"].instantiate(map)
    const prefab = prefabs["intro text"].instantiate(map)
    const prefab1 = prefabs.oozvr.instantiate(map,{
        beat: 2
    })
    const prefab2 = prefabs.planet.instantiate(map,{
        track: 'Planet',
        beat:0
    })
    prefabs["tau-ceti"].instantiate(map,{
        track: 'Sun'
    })
    const prefab3 = prefabs.astrophage.instantiate(map,{
        beat: 122
    })
    const prefab4 = prefabs["far astrophage"].instantiate(map,{
        beat: 122
    })
    const prefab5 = prefabs["astrophage backlight"].instantiate(map,{
        beat: 122
    })
    const prefab6 = prefabs["astrophage backlight 2"].instantiate(map,{
        beat: 122
    })
    prefabs.planet.instantiate(map,{
        beat: 227.9,
        track: 'Planet'
    })

    //Prefab Removal
    prefab0.destroyObject(15)
    prefab.destroyObject(9)
    prefab1.destroyObject(10)
    prefab2.destroyObject(122)
    prefab3.destroyObject(228)
    prefab4.destroyObject(228)
    prefab5.destroyObject(228)
    prefab6.destroyObject(228)

    //Tracks
    rm.animateTrack(map,{
        beat: 0,
        duration: 339.508972,
        track: 'Planet',
        animation: {
            position: [
                ['baseHeadPosition.xy',500,0],
                ['baseHeadPosition.xy',500,.36228],
                ['baseHeadPosition.xy',1000,.67155],
                ['baseHeadPosition.xy',2750,1]
            ],
            rotation: [
                [-112,4,182,0],
                [-218,61,78,1]
            ]
        }
    })
    rm.animateTrack(map,{
        beat: 0,
        duration: 339.508972,
        track: 'Sun',
        animation: {
            position: [90,645,-76],
            rotation: [79,-51,-12]
        }
    })
    rm.assignTrackParent(map,{
        beat: 0,
        childrenTracks: ['Sun'],
        parentTrack: 'Planet'
    })
    //Notemods
    map.colorNotes.filter(rm.after(0)).forEach(note => {
        if (note.color === rm.NoteColor.BLUE){
        note.animation.offsetPosition = [
            [5,10,-100,0],
            [0,0,0,.49,'easeOutSine']
        ]
        note.animation.localRotation = [
            [0,0,180,.15],
            [0,0,0,.43,'easeOutSine']
        ]
        note.animation.scale = [
            [0,0,0,.1],
            [1,1,1,.2]
        ]
        note.life = (15)
    }})
    map.colorNotes.filter(rm.after(0)).forEach(note => {
        if (note.color === rm.NoteColor.RED){
        note.animation.offsetPosition = [
            [-5,-10,-100,0],
            [0,0,0,.49,'easeOutSine']
        ]
        note.animation.localRotation = [
            [0,0,180,.15],
            [0,0,0,.43,'easeOutSine']
        ]
        note.animation.scale = [
            [0,0,0,.1],
            [1,1,1,.2]
        ]
        note.life = (15)
    }})
    
}

await Promise.all([
    doMap('HardStandard')
])

// ----------- { OUTPUT } -----------

pipeline.export({
    outputDirectory: '../OutputMaps'
})
