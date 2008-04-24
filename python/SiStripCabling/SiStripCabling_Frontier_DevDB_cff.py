# The following comments couldn't be translated into the new config version:

#FrontierDev/CMS_COND_STRIP"
import FWCore.ParameterSet.Config as cms

import CalibTracker.Configuration.Common.PoolDBESSource_cfi
siStripFedCabling = CalibTracker.Configuration.Common.PoolDBESSource_cfi.poolDBESSource.clone()
#replace siStripFedCabling.DBParameters.authenticationPath="/afs/cern.ch/cms/DB/conddb"
#replace siStripFedCabling.DBParameters.messageLevel=2
sistripconn = cms.ESProducer("SiStripConnectivity")

siStripFedCabling.connect = 'frontier://FrontierDev/CMS_COND_STRIP'
siStripFedCabling.toGet = cms.VPSet(cms.PSet(
    record = cms.string('SiStripFedCablingRcd'),
    tag = cms.string('SiStripFedCabling_20X')
))

