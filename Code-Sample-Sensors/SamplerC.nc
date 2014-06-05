#include "Sampler.h"

configuration SamplerC {}

implementation
{
  components MainC, LedsC, NoLedsC,
    new TimerMilliC() as Timer,
    SerialActiveMessageC as Serial,
    new SerialAMSenderC(0),
    SamplerP;

  components new SensirionSht11C() as TempAndHumid,
    new HamamatsuS1087ParC() as PhotoPar,
    new HamamatsuS10871TsrC() as PhotoTsr,
    new Msp430InternalVoltageC() as InternalVoltage,
    new Msp430InternalTemperatureC() as InternalTemperature;

  SamplerP.Read[unique(UQ_SAMPLER)] -> TempAndHumid.Temperature;
  SamplerP.Read[unique(UQ_SAMPLER)] -> TempAndHumid.Humidity;
  SamplerP.Read[unique(UQ_SAMPLER)] -> PhotoTsr;
  SamplerP.Read[unique(UQ_SAMPLER)] -> PhotoPar;
  SamplerP.Read[unique(UQ_SAMPLER)] -> InternalVoltage;
  SamplerP.Boot -> MainC;
  SamplerP.Timer -> Timer;
  SamplerP.Leds -> LedsC;
  SamplerP.SerialSplitControl -> Serial;
  SamplerP.AMSend -> SerialAMSenderC;
}
