//
//  AnalysisViewController.swift
//  AudioKitDemo
//
//  Created by Nicholas Arner on 3/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

class AnalysisViewController: UIViewController {
    
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var amplitudeLabel: UILabel!
    @IBOutlet var noteNameLabel: UILabel!
    @IBOutlet var amplitudePlot: AKInstrumentPropertyPlot!
    @IBOutlet var frequencyPlot: AKInstrumentPropertyPlot!
    var normalizedFrequency = AKInstrumentProperty(value: 0, minimum: 16.35, maximum: 30.87)
    @IBOutlet var normalizedFrequencyPlot: AKFloatPlot!
    
    let analyzer: AKAudioAnalyzer
    let microphone: Microphone

    let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
    
    let analysisSequence = AKSequence()
    let updateAnalysis = AKEvent()
    
    override init() {
        microphone = Microphone()
        analyzer = AKAudioAnalyzer(audioSource: microphone.auxilliaryOutput)
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        microphone = Microphone()
        analyzer = AKAudioAnalyzer(audioSource: microphone.auxilliaryOutput)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad(animated: Bool) {
        super.viewDidLoad(animated)
        
        AKOrchestra.addInstrument(microphone)
        AKOrchestra.addInstrument(analyzer)
        analyzer.play()
        microphone.play()
        
        let analysisSequence = AKSequence()
        var updateAnalysis = AKEvent()
        updateAnalysis = AKEvent(block: {
            self.updateUI()
            analysisSequence.addEvent(updateAnalysis, afterDuration: 0.1)
        })
        analysisSequence.addEvent(updateAnalysis)
        analysisSequence.play()
        
        amplitudePlot.property = analyzer.trackedAmplitude
        frequencyPlot.property = analyzer.trackedFrequency
        normalizedFrequencyPlot.minimum = 15
        normalizedFrequencyPlot.maximum = 32
    }
    
    func updateUI() {
        if analyzer.trackedAmplitude.value > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", analyzer.trackedFrequency.value)
            
            var frequency = analyzer.trackedFrequency.value
            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
                frequency = frequency / 2.0
            }
            while (frequency < Float(noteFrequencies[0])) {
                frequency = frequency * 2.0
            }
            
            normalizedFrequency.value = frequency
            normalizedFrequencyPlot.updateWithValue(frequency)
            
            var minDistance: Float = 10000.0
            var index = 0
            
            for (var i = 0; i < noteFrequencies.count; i++){
                
                var distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if (distance < minDistance){
                    index = i
                    minDistance = distance
                }
            }

            var octave = Int(log2f(analyzer.trackedFrequency.value / frequency))
            var noteName = String(format: "%@%d", noteNamesWithSharps[index], octave, noteNamesWithFlats[index], octave)
            noteNameLabel.text = noteName
        }
        amplitudeLabel.text = String(format: "%0.2f", analyzer.trackedAmplitude.value)
    }
}