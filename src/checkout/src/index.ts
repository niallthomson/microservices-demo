
'use strict';

import 'ts-helpers';
import 'source-map-support/register';
import 'reflect-metadata';
import './types';

import { Application } from './config/Application';

((global as unknown) as { FormData: unknown }).FormData = class FormData {};

export default new Application();