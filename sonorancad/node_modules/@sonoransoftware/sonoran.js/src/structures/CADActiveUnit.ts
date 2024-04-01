import { Instance } from '../instance/Instance';
import { Base } from './Base';

export interface CADActiveUnitStruct {
  id: number;
  accId: string;
  status: number;
  isPanic: boolean;
  location: string;
  aop: string;
  isDispatch: boolean;
  data: CADActiveUnitDataStruct;
}

interface CADActiveUnitStructPartial {
  id: number;
  accId: string;
  status: number;
  isPanic: boolean;
  location: string;
  aop: string;
  isDispatch: boolean;
  data: Partial<CADActiveUnitDataStruct>;
}

export interface CADActiveUnitDataStruct {
  apiId1: string;
  apiId2: string;
  unitNum: string;
  name: string;
  district: string;
  department: string;
  subdivision: string;
  rank: string;
  group: string;
} 

export type CADActiveUnitResolvable = CADActiveUnit | number;

export class CADActiveUnit extends Base {
  public id: number = -1;
  public accId: string = '';
  public status: number = 0;
  public isPanic: boolean = false;
  public location: string = '';
  public aop: string = '';
  public isDispatch: boolean = false;
  public data: CADActiveUnitDataStruct = {
    apiId1: '',
    apiId2: '',
    unitNum: '',
    name: '',
    district: '',
    department: '',
    subdivision: '',
    rank: '',
    group: ''
  };
  
  constructor(instance: Instance, data: any) {
    super(instance);
    if (data) this._patch(data);
  }

  public _patch(data: Partial<CADActiveUnitStructPartial>) {
    if (data.id !== undefined) this.id = data.id;
    if (data.accId !== undefined) this.accId = data.accId;
    if (data.status !== undefined) this.status = data.status;
    if (data.isPanic !== undefined) this.isPanic = data.isPanic;
    if (data.location !== undefined) this.location = data.location;
    if (data.aop !== undefined) this.aop = data.aop;
    if (data.isDispatch !== undefined) this.isDispatch = data.isDispatch;
    if (data.data !== undefined) {
      if (data.data.apiId1 !== undefined) this.data.apiId1 = data.data.apiId1;
      if (data.data.apiId2 !== undefined) this.data.apiId2 = data.data.apiId2;
      if (data.data.unitNum !== undefined) this.data.unitNum = data.data.unitNum;
      if (data.data.name !== undefined) this.data.name = data.data.name;
      if (data.data.district !== undefined) this.data.district = data.data.district;
      if (data.data.department !== undefined) this.data.department = data.data.department;
      if (data.data.subdivision !== undefined) this.data.subdivision = data.data.subdivision;
      if (data.data.rank !== undefined) this.data.rank = data.data.rank;
      if (data.data.group !== undefined) this.data.group = data.data.group;
    }
  }
}