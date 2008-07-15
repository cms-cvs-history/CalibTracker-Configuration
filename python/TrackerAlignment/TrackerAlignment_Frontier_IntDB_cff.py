import FWCore.ParameterSet.Config as cms

from Alignment.CommonAlignmentProducer.GlobalPosition_Frontier_IntDB_cff import *
import CalibTracker.Configuration.Common.PoolDBESSource_cfi
trackerAlignment = CalibTracker.Configuration.Common.PoolDBESSource_cfi.poolDBESSource.clone()
trackerAlignment.connect = 'frontier://FrontierInt/CMS_COND_21X_ALIGNMENT'
trackerAlignment.toGet = cms.VPSet(cms.PSet(
    record = cms.string('TrackerAlignmentRcd'),
    tag = cms.string('TrackerIdealGeometry210_mc')
), 
    cms.PSet(
        record = cms.string('TrackerAlignmentErrorRcd'),
        tag = cms.string('TrackerIdealGeometryErrors210_mc')
    ))
    

